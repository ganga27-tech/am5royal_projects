import asyncio
from sqlalchemy import text, select
from app.db.session import AsyncSessionLocal
from app.models.developer_portal import DevProject, DevProjectMember
from app.models.employee import Employee

async def migrate_project_head():
    print("Ensuring project_head_id column on dev_projects...")
    async with AsyncSessionLocal() as db:
        # 1. Add columns if not exist
        await db.execute(text("""
            ALTER TABLE dev_projects 
            ADD COLUMN IF NOT EXISTS project_head_id BIGINT REFERENCES employees(id) ON DELETE SET NULL;
        """))
        await db.execute(text("""
            ALTER TABLE dev_project_members 
            ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        """))
        await db.commit()
        print("Columns verified.")

        # 2. Find developer Vishal and QA Sarah
        dev_res = await db.execute(select(Employee).where(Employee.email == 'dev@am5royal.com'))
        dev_user = dev_res.scalar_one_or_none()

        qa_res = await db.execute(select(Employee).where(Employee.email == 'qa@am5royal.com'))
        qa_user = qa_res.scalar_one_or_none()

        # 3. Assign project heads
        projects_res = await db.execute(select(DevProject))
        projects = projects_res.scalars().all()

        for p in projects:
            if not p.project_head_id:
                if "QA" in p.name and qa_user:
                    p.project_head_id = qa_user.id
                    head_id = qa_user.id
                elif dev_user:
                    p.project_head_id = dev_user.id
                    head_id = dev_user.id
                else:
                    head_id = None

                if head_id:
                    # Check if already a member
                    m_res = await db.execute(
                        select(DevProjectMember).where(
                            DevProjectMember.project_id == p.id,
                            DevProjectMember.employee_id == head_id
                        )
                    )
                    m = m_res.scalar_one_or_none()
                    if not m:
                        db.add(DevProjectMember(project_id=p.id, employee_id=head_id, project_role="lead"))
                    else:
                        m.project_role = "lead"

        await db.commit()
        print("Project heads and lead memberships established.")

if __name__ == "__main__":
    asyncio.run(migrate_project_head())

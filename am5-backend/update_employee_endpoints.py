import re

with open("app/api/v1/endpoints/employees.py", "r") as f:
    content = f.read()

replacement_me = """@router.get("/me", response_model=EmployeeResponse)
async def read_employee_me(
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    from sqlalchemy import text
    from datetime import date
    
    res = await db.execute(text("SELECT points FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": date.today()})
    today_points = res.scalar_one_or_none() or 0
    
    return {
        "id": current_employee.id,
        "first_name": current_employee.first_name,
        "last_name": current_employee.last_name,
        "email": current_employee.email,
        "phone_number": current_employee.phone_number,
        "role": current_employee.role,
        "status": current_employee.status,
        "referral_points": today_points
    }
"""

replacement_list = """@router.get("/", response_model=List[EmployeeResponse])
async def list_employees(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_employee: Employee = Depends(get_current_employee)
):
    from sqlalchemy import text
    from datetime import date

    query = select(Employee).offset(skip).limit(limit)
    result = await db.execute(query)
    employees = result.scalars().all()
    
    res = await db.execute(text("SELECT employee_id, points FROM employee_daily_points WHERE date = :today"), {"today": date.today()})
    daily_points_map = {row[0]: row[1] for row in res.fetchall()}
    
    response = []
    for emp in employees:
        response.append({
            "id": emp.id,
            "first_name": emp.first_name,
            "last_name": emp.last_name,
            "email": emp.email,
            "phone_number": emp.phone_number,
            "role": emp.role,
            "status": emp.status,
            "referral_points": daily_points_map.get(emp.id, 0)
        })
    return response
"""

# Replace the specific functions using regex
content = re.sub(r'@router\.get\("/me", response_model=EmployeeResponse\)\nasync def read_employee_me\(\n    current_employee: Employee = Depends\(get_current_employee\)\n\):\n    return current_employee', replacement_me, content)
content = re.sub(r'@router\.get\("/", response_model=List\[EmployeeResponse\]\)\nasync def list_employees\([^)]+\):\n[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+\n    return employees', replacement_list, content)

with open("app/api/v1/endpoints/employees.py", "w") as f:
    f.write(content)

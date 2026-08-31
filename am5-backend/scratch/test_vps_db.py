import paramiko

def test_connection():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect('76.13.245.174', username='root', password='Am5royal@2026')
    
    stdin, stdout, stderr = client.exec_command('docker ps')
    print("Docker containers:\n", stdout.read().decode())
    
    # Run a test query against the postgres database
    cmd = '''docker exec -i am5_backend python -c "
import asyncio
from sqlalchemy import text
from app.db.session import engine

async def check():
    async with engine.connect() as conn:
        res = await conn.execute(text('SELECT count(*) FROM users WHERE role LIKE \\'%VENDOR%\\''))
        print('Total vendor users:', res.scalar())
        res2 = await conn.execute(text('SELECT count(*) FROM vendors'))
        print('Total vendors:', res2.scalar())

asyncio.run(check())
"'''
    stdin, stdout, stderr = client.exec_command(cmd)
    out = stdout.read().decode()
    err = stderr.read().decode()
    print("Query Output:\n", out)
    if err:
        print("Query Error:\n", err)
    client.close()

if __name__ == '__main__':
    test_connection()

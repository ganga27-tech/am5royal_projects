import re

with open("app/api/v1/endpoints/employees.py", "r") as f:
    content = f.read()

# Replace referral_points addition with a function call or block of code.
# Actually, since it's just 3 places, let's write a python snippet to replace them.
replacement = """
    from datetime import date
    from sqlalchemy import text
    
    current_employee.referral_points += 10
    
    # Update daily points
    today = date.today()
    check_query = text("SELECT id FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today")
    res = await db.execute(check_query, {"emp_id": current_employee.id, "today": today})
    if res.scalar_one_or_none():
        await db.execute(text("UPDATE employee_daily_points SET points = points + 10 WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": today})
    else:
        await db.execute(text("INSERT INTO employee_daily_points (employee_id, date, points) VALUES (:emp_id, :today, 10)"), {"emp_id": current_employee.id, "today": today})
"""

content = content.replace("    current_employee.referral_points += 10", replacement)

with open("app/api/v1/endpoints/employees.py", "w") as f:
    f.write(content)

print("Updated employees.py")

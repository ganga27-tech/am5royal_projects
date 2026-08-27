import paramiko

def test_endpoints():
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect('76.13.245.174', username='root', password='Am5royal@2026')
    
    endpoints = [
        ("GET", "/health", "Health check (should be 200)"),
        ("POST", "/api/v1/auth/customer/send-otp", "Customer Send OTP (should be 422 Unprocessable Entity for empty body)"),
        ("GET", "/api/v1/auth/customer/me", "Customer Profile (should be 401/403 for unauthorized)"),
        ("GET", "/api/v1/location/addresses", "Customer Addresses (should be 401/403 for unauthorized)"),
        ("GET", "/api/v1/catalog/packages", "Customer Packages (should be 200)"),
        ("GET", "/api/v1/catalog/categories/by-pincode?pincode=500001", "Customer Categories by pincode (should be 200)"),
        ("GET", "/api/v1/vendors/locations", "Vendor Locations (should be 200)"),
        ("GET", "/api/v1/vendor/catalog/main-categories", "Vendor Main Categories (should be 200)"),
    ]
    
    for method, path, desc in endpoints:
        cmd = f"curl -s -o /dev/null -w '%{{http_code}}' -X {method} http://localhost:8000{path}"
        stdin, stdout, stderr = c.exec_command(cmd)
        code = stdout.read().decode().strip()
        print(f"[{code}] {method} {path} - {desc}")
        
    c.close()

if __name__ == "__main__":
    test_endpoints()

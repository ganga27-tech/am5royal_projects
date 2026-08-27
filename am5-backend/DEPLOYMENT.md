# FastAPI Backend - Hostinger VPS Deployment Guide

This document describes how to deploy and manage the FastAPI Marketplace Backend on the Hostinger VPS (`76.13.245.174`).

---

## 🏗️ Architecture & Port Mappings
The application runs in **Docker** using `network_mode: host` to directly share the network namespace of the VPS (allowing seamless connection to Postgres on `localhost:5433`).

*   **API Service (FastAPI):** Port `8000` (Exposed to public)
*   **Cache Service (Redis):** Port `6379` (Internal to host)

---

## ⚡ Option 1: Automated Deployment (Recommended)
An automated Python deployment script is available in `scratch/deploy.py`. It automates file transfers, settings translation, and container building.

To run it from your local machine:
1. Ensure the Python virtual environment is active:
   ```bash
   source venv/bin/activate
   ```
2. Run the deployment script:
   ```bash
   python scratch/deploy.py
   ```
This script will connect via SSH/SFTP, upload files, adjust the database ports in `.env`, and rebuild/restart the Docker containers.

---

## 🛠️ Option 2: Manual Deployment Step-by-Step

If you prefer to run the commands manually:

### Step 1: Copy Local Code to VPS
From your local terminal, run `rsync` to sync files to the VPS (excluding local directories like `venv`):
```bash
rsync -avz --exclude 'venv' --exclude 'scratch' --exclude '.git' -e ssh ./ root@76.13.245.174:/root/am5-backend
```
*(Enter VPS password `Am5royal@2026` when prompted).*

### Step 2: SSH into the VPS
Connect to your Hostinger server via SSH:
```bash
ssh root@76.13.245.174
```

### Step 3: Configure `.env` on VPS
Go to the project folder on the server:
```bash
cd /root/am5-backend
```
Ensure `.env` matches the production settings (Port should be `5432` instead of the local development port `5433`):
```ini
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_USER=am5royal_user
POSTGRES_PASSWORD=am5royal_db_password_12345678
POSTGRES_DB=am5royal
REDIS_URL=redis://localhost:6379/0
```

### Step 4: Run Docker Compose
Build the image and start the containers in detached (background) mode:
```bash
docker compose up -d --build
```

---

## 🛡️ Firewall & Security Management (UFW)
The API runs on port `8000`. To manage access on the VPS:

*   **Allow public access to API:**
    ```bash
    ufw allow 8000/tcp
    ufw reload
    ```
*   **Check firewall status:**
    ```bash
    ufw status
    ```

---

## 📊 Monitoring & Logging
To view logs or manage containers on the VPS:

*   **View live logs:**
    ```bash
    docker logs am5_backend -f
    ```
*   **Check running containers:**
    ```bash
    docker ps
    ```
*   **Stop the application:**
    ```bash
    docker compose down
    ```

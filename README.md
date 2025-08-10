<h1 align="center">🚀 Deployment Automation to AWS ECS Fargate</h1>

<p align="center">
  <em>CI/CD pipeline using GitHub Actions + Terraform to deploy containerized apps to AWS ECS Fargate</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-ECS%20Fargate-orange?style=for-the-badge&logo=amazon-aws" />
  <img src="https://img.shields.io/badge/IaC-Terraform-purple?style=for-the-badge&logo=terraform" />
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?style=for-the-badge&logo=github-actions" />
  <img src="https://img.shields.io/badge/Docker-Ready-blue?style=for-the-badge&logo=docker" />
</p>

---

## 📌 Overview

This repository provides a **fully automated deployment pipeline** that:

1. **Detects changes** in your app code folder.
2. **Builds & pushes** Docker images to **Amazon ECR**.
3. **Deploys** the updated container to **AWS ECS Fargate**.
4. Uses **Terraform** for infrastructure provisioning.

---

## 🗂 Project Structure

```plaintext
Deployment-automation/
│
├── Source-Code-FIle-Folder/     # Application source code & Dockerfile
├── terraform/                   # Terraform IaC configuration files
│   ├── main.tf
│   ├── variables.tf
│   ├── iam.tf
│   ├── version.tf
│
└── .github/workflows/           # GitHub Actions workflows
    ├── docker-build.yml
    ├── terraform-deploy.yml
    ├── check-dockerfile.yml
```
Workflow Diagram
<p align="center"> <img src="" alt="Deployment Workflow" width="700"/> </p>

 Required GitHub Secrets
| Secret Name             | Description                    |
| ----------------------- | ------------------------------ |
| `AWS_ACCESS_KEY_ID`     | AWS access key for deployment  |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for deployment  |
| `AWS_REGION`            | AWS region (e.g., `us-east-1`) |
| `AWS_ACCOUNT_ID`        | Your AWS account ID            |
| `ECR_REPOSITORY`        | Name of your ECR repository    |

⚙️ How It Works
<div align="center">
Step	Action
1️⃣	Developer pushes code into Source-Code-FIle-Folder/
2️⃣	GitHub Actions detects changes
3️⃣	Docker image is built & pushed to Amazon ECR
4️⃣	Terraform provisions ECS cluster, task, and service
5️⃣	ECS Fargate runs the updated container

</div>

 Quick Start
 
bash
Copy
Edit
# 1. Clone the repository
git clone https://github.com/Mohammedmushtaq0/Deployment-automation.git
cd Deployment-automation

# 2. Add your source code
# Place your files & Dockerfile in:
Source-Code-FIle-Folder/

# 3. Commit & Push
git add .
git commit -m "Add my app source code"
git push origin main
📌 Watch the Actions tab to see the automation in progress.

🛠 Technologies Used
<p align="center"> <img src="https://img.shields.io/badge/AWS-ECS%20Fargate-orange?style=for-the-badge&logo=amazon-aws" /> <img src="https://img.shields.io/badge/Terraform-IaC-purple?style=for-the-badge&logo=terraform" /> <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-blue?style=for-the-badge&logo=github-actions" /> <img src="https://img.shields.io/badge/Docker-Containerization-blue?style=for-the-badge&logo=docker" /> </p>

📄 License
This project is licensed under the MIT License.

<h3 align="center">💡 Pro Tip:</h3> <p align="center"> If you replace the diagram in <code>docs/deployment-diagram.png</code> with your own, it will auto-update in the README. </p> ```

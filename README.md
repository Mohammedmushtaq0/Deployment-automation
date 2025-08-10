# Deployment-automation
Deployment Automation to AWS ECS Fargate
This repository contains a fully automated CI/CD pipeline for deploying containerized applications to AWS ECS (Fargate) using GitHub Actions and Terraform.

It automatically:

Detects changes in your application code folder.

Builds a Docker image from your app's Dockerfile.

Pushes the image to Amazon ECR.

Provisions and deploys to AWS ECS Fargate using Terraform.

📌 Project Structure
bash
Copy
Edit
Deployment-automation/
│
├── Source-Code-FIle-Folder/     # Your application source code & Dockerfile
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
🖼 Visual Workflow Diagram

(Replace docs/deployment-diagram.png with your actual PNG path in the repo)

🔑 Required GitHub Secrets
Before using this workflow, add the following repository secrets in your GitHub repo settings:

Secret Name	Description
AWS_ACCESS_KEY_ID	AWS access key for deployment
AWS_SECRET_ACCESS_KEY	AWS secret key for deployment
AWS_REGION	AWS region (e.g., us-east-1)
AWS_ACCOUNT_ID	Your AWS account ID
ECR_REPOSITORY	Name of your ECR repository

⚙️ How It Works
Push Application Code

Add your source code and Dockerfile inside Source-Code-FIle-Folder/

Commit & push changes to the main branch

GitHub Actions Workflow

docker-build.yml triggers when files in Source-Code-FIle-Folder/ change

Builds a Docker image & pushes to Amazon ECR

Terraform Deployment

terraform-deploy.yml runs after Docker image is pushed

Provisions ECS Fargate cluster, task definition, and service

Application Runs on AWS

The service runs in ECS using the pushed Docker image

🚀 Usage Steps
Clone this repository

bash
Copy
Edit
git clone https://github.com/<your-username>/Deployment-automation.git
cd Deployment-automation
Add Your App Source Code

Place your application files & Dockerfile inside:

css
Copy
Edit
Source-Code-FIle-Folder/
Commit & Push

bash
Copy
Edit
git add .
git commit -m "Add my app source code"
git push origin main
Watch the Actions Tab

GitHub Actions will build, push, and deploy automatically

🛠 Technologies Used
AWS ECS (Fargate) – Serverless container hosting

Amazon ECR – Docker image registry

Terraform – Infrastructure as Code

GitHub Actions – CI/CD automation

Docker – Containerization

📄 License
This project is licensed under the MIT License.

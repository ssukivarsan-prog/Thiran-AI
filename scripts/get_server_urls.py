"""
Thiran AI - Server & Service URL Directory
"""

def print_urls():
    print("=" * 60)
    print(">>> THIRAN AI - ACTIVE SERVICE URLS <<<")
    print("=" * 60)
    print("\n[1] Python FastAPI Backend (Port 8000)")
    print("    * Base URL:         http://localhost:8000")
    print("    * Health Check:     http://localhost:8000/health")
    print("    * Readiness Check:  http://localhost:8000/ready")
    print("    * API Docs:         http://localhost:8000/docs")
    print("    * Command:          python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload")
    
    print("\n[2] Node.js / TypeScript Backend (Port 4000)")
    print("    * Base URL:         http://localhost:4000")
    print("    * Health Check:     http://localhost:4000/health")
    print("    * Readiness Check:  http://localhost:4000/ready")
    print("    * Command:          cd backend && npm run dev")
    
    print("\n[3] Flutter Web Application (Port 3000)")
    print("    * Operations App:   http://localhost:3000")
    print("    * Command:          cd web_flutter && flutter run -d chrome --web-port 3000")
    
    print("\n[4] Flutter Mobile Application")
    print("    * Command:          cd mobile_flutter && flutter run")
    print("=" * 60)

if __name__ == "__main__":
    print_urls()

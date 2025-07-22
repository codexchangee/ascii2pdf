FROM python:3.9-slim

LABEL maintainer="codexchangee"
LABEL description="Converts ASCII and .txt files to PDF without .pdf extension"

# Install required tools
RUN apt-get update && apt-get install -y file && \
    pip install fpdf && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create directories for input/output
RUN mkdir -p /data/incoming /data/outgoing

# Embed the Python logic in the image
RUN echo "\
import os\n\
import time\n\
import subprocess\n\
from fpdf import FPDF\n\
\n\
INPUT_DIR = '/data/incoming'\n\
OUTPUT_DIR = '/data/outgoing'\n\
\n\
def is_convertible_file(filepath):\n\
    try:\n\
        output = subprocess.check_output(['file', '--mime', filepath]).decode()\n\
        return 'text/plain' in output or 'charset=us-ascii' in output\n\
    except Exception as e:\n\
        print(f'[!] file check error: {e}')\n\
        return False\n\
\n\
def text_to_pdf(input_path, output_path):\n\
    pdf = FPDF()\n\
    pdf.add_page()\n\
    pdf.set_font('Courier', size=12)\n\
    with open(input_path, 'r', errors='ignore') as file:\n\
        for line in file:\n\
            pdf.cell(200, 10, txt=line.strip(), ln=True)\n\
    pdf.output(output_path)\n\
\n\
print('[*] Watching for ASCII and .txt files in', INPUT_DIR)\n\
\n\
while True:\n\
    time.sleep(2)\n\
    for filename in os.listdir(INPUT_DIR):\n\
        in_path = os.path.join(INPUT_DIR, filename)\n\
        out_path = os.path.join(OUTPUT_DIR, filename)\n\
        if os.path.isfile(in_path) and is_convertible_file(in_path):\n\
            if not os.path.exists(out_path):\n\
                print(f'[+] Converting: {filename}')\n\
                try:\n\
                    text_to_pdf(in_path, out_path)\n\
                except Exception as e:\n\
                    print(f'[!] Failed to convert {filename}: {e}')\n\
" > /app/app.py

CMD ["python3", "/app/app.py"]


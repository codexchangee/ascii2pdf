FROM registry.access.redhat.com/ubi8/ubi

LABEL maintainer="codexchange"
LABEL description="ASCII to PDF converter container"

# Install dependencies
RUN dnf install -y python3 python3-pip && \
    pip3 install fpdf && \
    mkdir -p /data/incoming /data/outgoing

# Add convert.py using echo -e (for proper newlines)
RUN echo -e '#!/usr/bin/env python3\n\
import os\n\
from fpdf import FPDF\n\
\ndef convert_txt_to_pdf(txt_path, pdf_path):\n\
    pdf = FPDF()\n\
    pdf.add_page()\n\
    pdf.set_font("Arial", size=12)\n\
    with open(txt_path, "r") as file:\n\
        for line in file:\n\
            pdf.cell(200, 10, txt=line.strip(), ln=1)\n\
    pdf.output(pdf_path)\n\
\n\
if __name__ == "__main__":\n\
    import sys\n\
    if len(sys.argv) != 3:\n\
        print("Usage: convert.py input.txt output.pdf")\n\
        exit(1)\n\
    convert_txt_to_pdf(sys.argv[1], sys.argv[2])\n' > /usr/local/bin/convert.py && \
    chmod +x /usr/local/bin/convert.py

# Add entrypoint.sh using echo -e
RUN echo -e '#!/bin/bash\n\
IN_DIR="/data/incoming"\n\
OUT_DIR="/data/outgoing"\n\
echo "Watching $IN_DIR..."\n\
while true; do\n\
  for file in "$IN_DIR"/*.txt; do\n\
    [ -e "$file" ] || continue\n\
    base=$(basename "$file" .txt)\n\
    out="$OUT_DIR/$base"\n\
    /usr/bin/python3 /usr/local/bin/convert.py "$file" "$out"\n\
    echo "Converted $file -> $out"\n\
    rm -f "$file"\n\
  done\n\
  sleep 2\n\
done\n' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/data/incoming", "/data/outgoing"]

CMD ["/usr/local/bin/entrypoint.sh"]

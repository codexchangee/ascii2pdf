🔤 ASCII to PDF Converter (Containerized)

This containerized tool **watches a directory for `.ascii` or `.txt` files** and automatically converts them into **valid PDF files** using a lightweight Python script with `fpdf`.  

- ✅ Supports **empty files** (produces blank but valid PDF)
- ✅ Works with `.ascii` and `.txt` extensions
- ✅ Outputs raw files without `.pdf` extension, but they are valid PDF documents
- ✅ Designed for automation, bulk conversion, and system integration


To use this : 

Kindly follow these steps: 

------------ Step to create Image -------------------
podman image build . -t watcher
podman image ls

------------- Create local directory -----------------
mkdir /opt/files
mkdir /opt/processed

chown Andrew:Andrew /opt/files
chown Andrew:Andrew /opt/processes

----------------------------------------------------------------------
ssh andrew@localhost  [ you can use any user name ]                  |
----------------------------------------------------------------------

---------------------- Create container and Service ---------------------------


podman container run -d –name watcher -v /opt/files:/data/incoming:Z -v /opt/processes:/data/outgoing:Z watcher
podman ps
mkdir -p ~/.config/systemd/user/
cd ~/.config/systemd/user/
podman generate systemd --name watcher --new –files
systemctl –user daemon-reload
systemctl --user start container-watcher.service
systemctl --user enable container-watcher.service
loginctl enable-linger

-------------------------- To Test ----------------------------------------

echo "Hello ASCII" > /opt/files/sample.txt
ls /opt/processes

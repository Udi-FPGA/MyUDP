import socket

# --- CONFIGURATION ---
FPGA_IP = "192.168.1.128"
FPGA_PORT = 1234
PC_PORT = 5678            # The port your PC is listening on

def listen_to_fpga():
    # 1. Create the UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    # 2. Bind the PC to the specific port
    # '' allows it to listen on any network interface
    sock.bind(('', PC_PORT))
    print(f"PC listening on port {PC_PORT}...")
    print(f"Waiting for packets from {FPGA_IP}:{FPGA_PORT}...")

    # Optional: Send a "ping" to the FPGA to get the conversation started
    # (The FPGA needs to know your IP/MAC to send back to you!)
    sock.sendto(b"HELLO_FPGA", (FPGA_IP, FPGA_PORT))
    Count = 0
    try:
        while True:
            # 3. Listen for incoming data
            # This will pause the script until a packet arrives
            data, addr = sock.recvfrom(4096)
            Count += 1
            print(f"--- Packet Received ---")
            print(f"From: {addr[0]}:{addr[1]}")
            print(f"Data: {data.decode('ascii', errors='replace')}")
            print(f"Raw Hex: {data.hex()}")
            print(f"Count: #{Count}")
            print("-" * 23)

    except KeyboardInterrupt:
        print("\nStopping listener...")
    finally:
        sock.close()

if __name__ == "__main__":
    listen_to_fpga()
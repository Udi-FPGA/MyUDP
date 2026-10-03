import socket
import time

# --- CONFIGURATION ---
FPGA_IP = "192.168.1.128"  # The IP from your Wireshark capture
FPGA_PORT = 1234           # The port seen in your Wireshark capture
PC_PORT = 5678            # <--- The specific port you want your PC to use
#MESSAGE = b"FPGA UDP Test 123" # The data to send (must be bytes)
#MESSAGE =  b"3234567893abcdefab3" # The data to send (must be bytes)
MESSAGE =  b"3" # The data to send (must be bytes)
TIMEOUT = 2.0              # Seconds to wait before giving up

def test_fpga():
    # 1. Create a UDP socket
    # AF_INET = IPv4, SOCK_DGRAM = UDP
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)

    print(f"Sending to {FPGA_IP}:{FPGA_PORT}...")
    
    try:
        # 2. Send the data
        sock.bind(('', PC_PORT))
        print(f"Socket bound to PC port: {PC_PORT}")
        start_time = time.time()
        sock.sendto(MESSAGE, (FPGA_IP, FPGA_PORT))

        # 3. Wait for the Echo response
        data, server = sock.recvfrom(4096)
        end_time = time.time()

        # 4. Calculate round-trip time and display results
        elapsed = (end_time - start_time) * 1000
        print("-" * 30)
        print(f"SUCCESS!")
        print(f"Received from: {server[0]}")
        print(f"Data received: {data.decode('ascii', errors='replace')}")
        print(f"Round-trip time: {elapsed:.2f} ms")
        print("-" * 30)

    except socket.timeout:
        print("-" * 30)
        print("ERROR: Timeout.")
        print("The FPGA did not send the data back.")
        print("Check if the FPGA is still powered on and connected.")
        print("-" * 30)
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        sock.close()

if __name__ == "__main__":
    test_fpga()
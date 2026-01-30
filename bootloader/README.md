# Fast A20 Control (Port 0x92)

- **Bit 0** of port `0x92` triggers a system reset.  
- Always preserve bit 0 when modifying this port.

## Fast A20 Enable / Disable

```asm
; Enable Fast A20 (set bit 1)
in   al, 0x92
or   al, 00000010b
out  0x92, al

; Disable Fast A20 (clear bit 1)
in   al, 0x92
and  al, 11111101b
out  0x92, al
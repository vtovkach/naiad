# OS-Experiments

This repository contains low-level operating system experiments.
---

## Mini Bootloader Architecture

The bootloader is split into multiple stages. Each stage performs a specific task
required to gradually bring the system to a goal. 

---

## Stage 1 — Initial Boot (Real Mode)

**Responsibilities:**
- Initialize segment registers (`SS:SP`, `DS`, `ES`)
- Enable the A20 gate
- Load Stage 2 into memory
- Jump to Stage 2

---

## Stage 2 — Hardware Discovery & Setup

**Responsibilities:**
- Collect the system memory map using E820 and store it in a buffer
- Prepare for protected mode
- Build a minimal Global Descriptor Table (GDT)

---

## Stage 3 — Protected Mode Transition

**Responsibilities:**
- Switch the CPU to protected mode
- Confirm protected mode by displaying a message

---

## Stage 4 — Memory Layout Display

**Responsibilities:**
- Display the E820 memory layout
- Show usable and reserved memory regions

---

## Stage 5 — Halt

**Responsibilities:**
- Halt CPU execution safely

---

## Goals

- Learn the x86 boot process in depth
- Practice bare-metal programming
- Build a foundation for future kernel development

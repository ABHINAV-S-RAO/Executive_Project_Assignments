# Simulated Annealing – Intuition, Math & Verilog Implementation

Simulated Annealing (SA) is an optimization technique inspired by the way metals are heated and then slowly cooled so their atoms settle into a stable, low-energy structure.

To make it beginner-friendly, let’s use a simple analogy.

---

##  Hoop Game Analogy (Super Intuitive Explanation)

Remember the classic *kids' hoop water game* where you push buttons to make rings land on sticks?

<img width="250" height="238" alt="image" src="https://github.com/user-attachments/assets/17c25bc1-84a6-4332-9a83-8cbdef0f5f51" />


This is EXACTLY how simulated annealing behaves:

- **At first**, you press buttons randomly - water blasts everywhere and hoops fly around.
  - You are NOT careful.
  - Anything can happen, and that’s fine.

- **Later**, when hoops start landing correctly, you become VERY careful:
  - Tiny taps.
  - You avoid messing up what you already achieved.

Simulated annealing works the same way:

| Hoop Game | Simulated Annealing |
|----------|---------------------|
| Big chaotic moves | High temperature (T is large) |
| Accept anything | Many bad moves get accepted |
| Later slow/gentle moves | Temperature decreases |
| Very selective | Bad moves rarely accepted |

This mix of early randomness + late precision allows SA to escape local minima and find better solutions.

---

##  Core Steps of the Algorithm

Every iteration does:

### **1. Pick a random neighbor**
A small random change to the current value of `x`.

### **2. Compute the cost difference**

## **Delta E = E(x_new) - E(x_curr)**


### **3. Decide whether to accept**
- If **ΔE < 0**, accept — it’s a better solution.
- Otherwise, accept with probability:

 **P = e^{DeltaE / T}**


This probability shrinks as **T → 0**, which means the algorithm becomes more selective over time.

---

##  What Is *x* in This Project?

- `x` is the value being optimized.
- Stored in **Q4.12 fixed-point format** (16-bit signed).
- New neighbors generated as:

## **x_new = x + small random step**


This “step” is exactly like giving the hoop toy a tap — sometimes big, sometimes small.

---

##  Cost Function

The function being minimized is:


## **E(x) = x^4 - 10x^2 + 9x**
<img width="1121" height="674" alt="image" src="https://github.com/user-attachments/assets/59c70fb4-de4b-427e-aaa9-6657558c1ccf" />


This function has several local minima, which is why SA is ideal - it avoids getting stuck early.
The expected solution x should be around -2.3 which can be achieved through high level C and Verilog implementations

---

##  Understanding the Formula

### **If temperature is HIGH:**


 **P = e^{-Delta E / T}** is approx 1


Meaning:
- Even bad moves get accepted.
- Encourages exploration.

### **If temperature is LOW:**


 **e^{Delta E / T}**  is approx 0


Meaning:
- Almost NO bad moves are accepted.
- Algorithm stabilizes.
- You "lock in" on the good region.

This mirrors the hoop game:
- Early: chaotic button mashing.
- Late: careful precision.

---

##  Pseudocode 
current_state = random

#### for T = T_start down to T_min:
#### neighbor = random_neighbor(current_state)
#### ΔE = cost(neighbor) - cost(current_state)
#### 
#### if ΔE < 0:
####   accept
#### else:
####    accept with probability exp(-ΔE / T)


---

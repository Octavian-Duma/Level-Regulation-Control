# Level Control using PI, Feedforward, Cascade, and Arduino-Based Discrete Control

## Overview
This project presents the modeling, identification, and control of a liquid level process built on the **Festo Process Control System** and implemented in **MATLAB/Simulink**.

The main objective was to regulate the water level in the main tank despite disturbances affecting the inlet and outlet flow. The project starts from a nonlinear process model, derives simplified linear models around a chosen operating point, and compares several control strategies based on **PI regulation**, **feedforward compensation**, and **cascade control**.

As a practical extension, the project also includes an **Arduino-based discrete controller** that implements the **outer cascade loop** directly on hardware, demonstrating real-time digital control and practical deployability.

## Control Objective
The goal was to maintain the level of the main tank at the desired reference while rejecting disturbances as quickly as possible.

The main disturbance sources considered were:
- **outlet flow disturbances** caused by changes in valve **V112**
- **inlet flow disturbances** caused by changes in valve **V101**

## Main Contributions
- Developed and implemented a **nonlinear Simulink model** of the Festo level control plant
- Modeled the main physical subsystems: amplifier, DC motor, centrifugal pump, pump efficiency, rotor current, tank dynamics, level sensors, filter block;
- Identified simplified **first-order process models** around the operating point
- Designed **PI controllers** for the classical feedback structure
- Studied disturbance rejection for both **inlet** and **outlet** flow perturbations
- Implemented and compared:
  - **classical PI feedback control**
  - **feedforward compensation**
  - **cascade control**
  - **combined cascade + feedforward control**
- Implemented a **discrete outer-loop controller on Arduino**
- Integrated Arduino communication with Simulink for real-time closed-loop testing

## Process Description
The setup consists of two vertically stacked water tanks with equal cross-sectional area. The controlled variable is the **level in Tank 1**, while Tank 2 acts as a buffer tank.

The manipulated variable is the command voltage applied to the pump amplifier, which drives a DC motor and centrifugal pump. The pump supplies inlet flow to the main tank, while the outlet flow is affected by valve settings and gravity.

The process includes:
- an analog ultrasonic level sensor
- flow sensors
- a pump driven by a DC motor
- amplifier saturation and nonlinearities
- nonlinear tank and outlet-flow dynamics

## Modeling
A nonlinear model of the plant was developed in Simulink based on the physical behavior of the laboratory setup.

The model includes:
- **amplifier nonlinearity and saturation**
- **motor static equations**
- **pump characteristic approximation**
- **pump efficiency approximation**
- **rotor current calculation**
- **tank mass balance**
- **gravitational outlet flow**
- **level sensor scaling**
- **first-order filtering** to avoid algebraic-loop issues

This produced a process-oriented simulation model suitable for controller design and disturbance analysis.

## System Identification
To design linear controllers, the nonlinear process was approximated around a nominal operating point.

In the personal implementation, the MATLAB script shows an updated identified model with:
- **process gain:** `K = 2.464`
- **time constant:** `T = 190 s`

The script also includes verification by comparing Simulink output data against the identified transfer function response.

For the cascade structure, the identified models used in the scripts are:
- **outer loop:** `K = 0.425`, `T = 420 s`
- **inner loop:** `K = 12.34`, `T ≈ 0.79 s`

## Classical PI Control
A PI controller was designed for the level loop to eliminate steady-state error and achieve acceptable reference tracking.

In the personal implementation, the MATLAB script computes the PI controller from the identified model using:
- `T_process = 190`
- `K_process = 2.464`
- `T0 = 47.5`

This produces a PI controller tuned directly from the first-order approximation of the plant.

## Disturbance Rejection Problem
The classical PI controller removes steady-state error, but disturbance rejection remains relatively slow.

The report shows that for a disturbance applied at the process input, the classical PI structure leads to:
- **system response time:** about **160 s**
- **disturbance rejection time:** about **800 s**

This motivates the use of more advanced control structures.

## Feedforward Compensation
To improve rejection of **outlet-flow disturbances**, a **feedforward compensation structure** was introduced.

The main idea is to use measured disturbance information to compensate its effect before it propagates through the plant. In the report, this is motivated by directly compensating variations in outlet flow.

This leads to a feedforward compensation factor:
`k_comp = 0.081`

## Cascade Control
A cascade control structure was introduced to improve the dynamic response by separating the control task into:
- an **inner fast loop** acting on flow-related dynamics
- an **outer slow loop** regulating tank level

This is a natural choice because the process contains fast actuator/flow dynamics and much slower level dynamics.

From the MATLAB script:
- the **inner loop** is identified with a very small time constant (`T ≈ 0.79 s`)
- the **outer loop** is identified as a slower first-order process (`K = 0.425`, `T = 420 s`)

The inner PI controller was tuned for two candidate closed-loop speeds:
- `T0 = 1 s`
- `T0 = 0.25 s`

The outer PI controller was tuned with:
- `T0 = 47.5 s`

This structure improves performance by making the outer loop act on a faster inner closed-loop subsystem.

## Combined Cascade + Feedforward Structure
The most advanced structure in the project combines **cascade control** with **feedforward compensation**.

The report explains that because the internal controller regulates flow and the outer controller regulates level, the disturbance on outlet flow can be compensated by adding the measured flow difference directly to the internal reference. In this way, the inlet flow is corrected to match the outlet-flow variation more directly.

This combined strategy provides the most complete disturbance-handling framework in the project:
- cascade improves dynamic response
- feedforward compensates measurable disturbances directly

## Arduino-Based Discrete Controller
The main personal contribution of the project is the practical implementation of the **outer cascade loop as a discrete PI controller on Arduino**.

The Arduino implementation uses:
- **sampling time:** `Ts = 0.5 s`
- **serial communication:** `19200 baud`
- controller parameters:
  - `Kp = 20.8`
  - `Ti = 420`

The controller implements an **incremental discrete PI** form: $$c[k] = c[k-1] + b_0 e[k] + b_1 e[k-1]$$

With coefficients:
- `b0 = Kp`
- `b1 = -Kp(1 - Ts/Ti)`

Where `Kp` = proportional gain, `Ti` = integral time, `Ts` = sampling period.

The code exchanges float values with Simulink over serial by packing and unpacking 4-byte data packets. This allows Simulink to send the current error to the Arduino and receive the computed control command back in real time.

This is an important practical extension because it shows that the cascade strategy is not only valid in simulation, but also implementable as a digital controller on embedded hardware.

## Results
The project shows a clear progression from basic to advanced control structures:

- the **classical PI controller** achieves zero steady-state error but relatively slow disturbance rejection
- the **FRTool-tuned PI** improves response time significantly, reaching about:
  - **90 s** response time
  - **80 s** disturbance-response time
  although at the cost of larger overshoot
- **feedforward compensation** improves rejection of measurable outlet disturbances
- **cascade control** improves the dynamic behavior by separating fast and slow dynamics
- **combined cascade + feedforward** provides the most advanced disturbance-handling structure in the project
- the **Arduino implementation** demonstrates practical real-time execution of the discrete outer controller

## Engineering Concepts
This project demonstrates a complete control-engineering workflow:
1. nonlinear physical modeling
2. Simulink implementation
3. local linear identification around an operating point
4. PI controller design
5. disturbance analysis
6. advanced control structures
7. embedded digital implementation on Arduino

It also shows an important transition from a purely simulation-based design to a **practical real-time implementation**, which is highly relevant for industrial automation and control applications.

## Tools and Technologies
- MATLAB
- Simulink
- Control System Toolbox
- Festo Process Control System
- Arduino


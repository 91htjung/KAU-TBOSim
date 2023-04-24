# mod

# 주석 처리된 문장은 MATLAB내 ampl API에서 직접 입력되는 문장
# 그 외 모든 Data는 MATLAB에서 입력됨.

set Arc;

param Time{Arc} >= 0;
param Tau{Arc} >= 0;

param EET >= 0;

param TimeResolution;
param TauStep;

param Mass;

param MaxSpeed_ST;
param MinSpeed_ST;
param MaxSpeed_EN;
param MinSpeed_EN;

param LongAccelLimit;

param rho_ST;
param rho_EN;
param gravity;

param DragCoeff1;
param DragCoeff2;

param Bankangle;
param Surface;

param ThrustCoeff1;
param ThrustCoeff2;
param ThrustCoeff3;
param ThrustCoeff4;
param ThrustCoeff5;

param FuelCoeff1;
param FuelCoeff2;
param FuelCoeff3;
param FuelCoeff4;
param FuelCoeff5;

param Heading_P0;
param Heading_P3;

param Airspeed_P0;
param Airspeed_P3;

param Altitude_P0;
param Altitude_P3;

param Length;
param Length_x;
param Length_y;

param LongDistance;
param LongAngle;
param VertDistance;
param VertAngle;

param P0_x;
param P0_y;

param P3_x;
param P3_y;

# param Altitude{a in Arc} = Altitude_P0 * (1 - Tau[a]) + Altitude_P3 * Tau[a];

var lambda0;
var lambda1;


# var P1_x{a in Arc} = P0_x + (lambda0 * Tau[a] + 1/3) * Length * cos(Heading_P0);
# var P1_y{a in Arc} = P0_y + (lambda0 * Tau[a] + 1/3) * Length * sin(Heading_P0);

# var P2_x{a in Arc} = P3_x + (lambda1 * (Tau[a] - 1) - 1/3) * Length * (cos(Heading_P3) * cos(VertAngle));
# var P2_y{a in Arc} = P3_y + (lambda1 * (Tau[a] - 1) - 1/3) * Length * (sin(Heading_P3) * cos(VertAngle));

# var P_x{a in Arc} = ((1-Tau[a])^3)*P0_x + 3*((1-Tau[a])^2)*Tau[a]*P1_x[a] + 3*(1-Tau[a])*(Tau[a]^2)*P2_x[a] + Tau[a]^3*P3_x;
# var P_y{a in Arc} = ((1-Tau[a])^3)*P0_y + 3*((1-Tau[a])^2)*Tau[a]*P1_y[a] + 3*(1-Tau[a])*(Tau[a]^2)*P2_y[a] + Tau[a]^3*P3_y;

# var Velocity_x{a in Arc} = ((3 * (Tau[a] - 1) * (3 * Tau[a] - 1) * P1_x[a]) + (3 * Tau[a] * (2 - 3 * Tau[a]) * P2_x[a]) +
#    (3 * Tau[a]^2 * LongDistance * cos(LongAngle)) + (3 * Tau[a] * (1 - Tau[a])^2 * lambda0 * Length * cos(Heading_P0)) +
#    (3 * Tau[a]^2 + (1 - Tau[a]) * lambda1 * Length * cos(Heading_P3) * cos(VertAngle))) * (TauStep / TimeResolution);

# var Velocity_y{a in Arc} = ((3 * (Tau[a] - 1) * (3 * Tau[a] - 1) * P1_y[a]) + (3 * Tau[a] * (2 - 3 * Tau[a]) * P2_y[a]) +
#    (3 * Tau[a]^2 * LongDistance * cos(LongAngle)) + (3 * Tau[a] * (1 - Tau[a])^2 * lambda0 * Length * sin(Heading_P0)) +
#    (3 * Tau[a]^2 + (1 - Tau[a]) * lambda1 * Length * sin(Heading_P3) * cos(VertAngle))) * (TauStep / TimeResolution);


# var Acceleration_x{a in Arc} = ((3 * (6 * Tau[a] - 4) * P1_x[a]) + (3 * (2 - 6 * Tau[a]) * P2_x[a]) +
#    (6 * Tau[a] * LongDistance * cos(LongAngle)) + (3 * (Tau[a] - 1) * (3 * Tau[a] - 1) * lambda0 * Length * cos(Heading_P0)) +
#    (3 * Tau[a] * (2 - 3 * Tau[a]) * lambda1 * Length * cos(Heading_P3) * cos(VertAngle)))  * (TauStep / TimeResolution)^2;

# var Acceleration_y{a in Arc} = ((3 * (6 * Tau[a] - 4) * P1_y[a]) + (3 * (2 - 6 * Tau[a]) * P2_y[a]) +
#    (6 * Tau[a] * LongDistance * cos(LongAngle)) + (3 * (Tau[a] - 1) * (3 * Tau[a] - 1) * lambda0 * Length * sin(Heading_P0)) +
#    (3 * Tau[a] * (2 - 3 * Tau[a]) * lambda1 * Length * sin(Heading_P3) * cos(VertAngle)))  * (TauStep / TimeResolution)^2;

# var VerticalSpeed{a in Arc} = VertDistance / EET;

# var Lift{a in Arc} = Mass * 1000 * (gravity + Acceleration_y[a] * 1852);
# var Qs{a in Arc} = (rho_ST * (1 - Tau[a]) + rho_EN * Tau[a]) * ((sqrt(Velocity_x[a]^2 + Velocity_y[a]^2) * 1852) ^ 2) * Surface / 2;
# var LiftCoeff{a in Arc} = Lift[a] / Qs[a];

# var DragCoeff{a in Arc} = DragCoeff1 + DragCoeff2 * LiftCoeff[a]^2;
# var Drag{a in Arc} = DragCoeff[a] * Qs[a];

# var Thrust{a in Arc} = Drag[a] + Mass * 1000 * sqrt(Acceleration_y[a]^2 + Acceleration_x[a]^2) * 1852 / 1000;
# var MaxThrust{a in Arc} = ThrustCoeff1 * (1 - (Altitude[a] / ThrustCoeff2) + (ThrustCoeff3 * Altitude[a]^2));

# var Mu{a in Arc} = FuelCoeff1 * (sqrt(Velocity_x[a]^2 + Velocity_y[a]^2) / FuelCoeff2);
# var NominalFuelFlow{a in Arc} = Mu[a] * Thrust[a] / 60;
# var FuelUsed = NominalFuelFlow * FuelCoeff5 * TimeResolution;



##########	Objective Function	##########

# minimize Cost: sum{a in Arc} FuelUsed[a];



##########	Constraints	##########

# Constraint (1) Arc Length
# s.t. ArcLength: sum{a in Arc} abs(sqrt(Velocity_x[a]^2 + Velocity_y[a]^2) * TimeResolution -  Length) < 1;

# Constraint (2.1) Minimum Airspeed
# s.t. MaxSpeed{a in Arc}: Velocity_x[a]^2 + Velocity_y[a]^2 <=  (MaxSpeed_ST * (1 - Tau[a]) + MaxSpeed_EN * Tau[a])^2;

# Constraint (2.2) Maximum Airspeed
# s.t. MinSpeed{a in Arc}: Velocity_x[a]^2 + Velocity_y[a]^2 >=  (MinSpeed_ST * (1 - Tau[a]) + MinSpeed_EN * Tau[a])^2;

# Constraint (3) Maximum Acceleration
# s.t. MaxAcceleration{a in Arc}: Acceleration_x[a]^2 + Acceleration_y[a]^2 <= LongAccelLimit^2;

# Constraint (4) Maximum Thrust
# s.t. MaxThrust{a in Arc}: Thrust[a] <= MaximumThrust[a];

# Constraint (5) Maximum Rate of Turn
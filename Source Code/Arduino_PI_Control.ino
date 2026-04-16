const float Ts = 0.5f;
const unsigned long Ts_ms = 500;

const float Kp = 20.8f;
const float Ti = 420.0f;

const float b0 = Kp;
const float b1 = -Kp * (1.0f - Ts / Ti);

const float CONDITIE_INITIALA = 27.3f;

float c[2] = {CONDITIE_INITIALA, CONDITIE_INITIALA};
float e[2] = {0.0f, 0.0f};

union DataPackage {
  byte b[4];
  float fval;
};

unsigned long lastSampleTime = 0;

void setup() {
  Serial.begin(19200);
}

void loop() {
  unsigned long now = millis();

  if (now - lastSampleTime >= Ts_ms) {
    lastSampleTime += Ts_ms;    

    if (Serial.available() >= 4) {
      DataPackage inData;
      for (int i = 0; i < 4; i++) {
        inData.b[i] = Serial.read();
      }
      e[0] = inData.fval;
    }

    c[0] = c[1] + b0 * e[0] + b1 * e[1];

    DataPackage outData;
    outData.fval = c[0];
    Serial.write(outData.b, 4);

    c[1] = c[0];
    e[1] = e[0];
  }
}
// Integer array of the count data for the acceleration curve
const int count[] = {9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 27, 27, 28, 28, 29, 30, 31, 31, 32, 33, 34, 35, 36, 36, 37, 38, 39, 41, 42, 43, 44, 45, 47, 48, 49, 51, 52, 54, 55, 57, 59, 61, 63, 65, 67, 69, 71, 74, 76, 79, 82, 84, 87, 91, 94, 97, 101, 105, 109, 113, 117, 122, 127, 132, 138, 144, 150, 156, 163, 170, 178, 186, 195, 204, 214, 225, 236, 248, 261, 275, 289, 305, 322, 340, 360, 381, 404, 429, 456, 485, 517, 552, 589, 631, 676, 726, 781, 841, 908, 982, 1065};

// Step mode selector pin
const int mode0Pin = 2;
const int mode1Pin = 3;
const int mode2Pin = 4;

// Enable pin
const int enablePin = 8;

/*
  H-limit pin
  Logic high when high limit is reached
*/
const int highLimitPin = 10;

/*
  L-limit pin
  Logic high when low limit is reached
*/
const int lowLimitPin = 11;

// Direction pin
const int dirPin = 12;

// Step pin
const int stepPin = 13;

// Delimiters used in Serial communication
const char startMarker = '<';
const char endMarker = '>';
const char CAN = '\030';
const char ACK = '\006';

// Store received characters
const int maxNumChars = 16;
char receivedChars[maxNumChars];

// Indicate message status
boolean newMessage = false;
boolean validMessage = false;

#define DEBUG 0

void setup() {
  // Initialize serial interface
  Serial.begin(9600);
  #if DEBUG == 1
    Serial.println("---------- Debug Mode ----------");
    Serial.println("Do NOT use with LabVIEW / MATLAB");
  #else
    Serial.println("---------- Normal Mode ----------");
  #endif

  // Set pin modes
  pinMode(mode0Pin, OUTPUT);
  pinMode(mode1Pin, OUTPUT);
  pinMode(mode2Pin, OUTPUT);
  pinMode(enablePin, OUTPUT);
  pinMode(highLimitPin, INPUT);
  pinMode(lowLimitPin, INPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(stepPin, OUTPUT);

  // Enable DRV8825 (low -> enable, high -> disable)
  digitalWrite(enablePin, LOW);

  // Set direction of DRV8825 (high -> backward, low -> forward)
  digitalWrite(dirPin, HIGH);

  /*
    Microstepping setting for testing
    000: Full step
    001: Half step
    010: 4 microsteps/step
    011: 8 microsteps/step
    100: 16 microsteps/step
    101/110/111: 32 microsteps/step
  */
  // Microstepping setting for testing
  // digitalWrite(mode0Pin, HIGH);
  // digitalWrite(mode1Pin, HIGH);
  // digitalWrite(mode2Pin, HIGH);

  /*
    Microstepping setting for testing
    000: Full step
    001: Half step
    010: 4 microsteps/step
    011: 8 microsteps/step
    100: 16 microsteps/step
    101/110/111: 32 microsteps/step
  */
  // Microstepping setting for actual use
  digitalWrite(mode0Pin, LOW);
  digitalWrite(mode1Pin, LOW);
  digitalWrite(mode2Pin, HIGH);
}

void loop() {
  getMessage();
  if (newMessage) {
    validateMessage();
    #if DEBUG == 1
      Serial.print("Message received: ");
      Serial.print(startMarker);
      Serial.print(receivedChars);
      Serial.print(endMarker);
      Serial.print(", Valid: ");
      if (validMessage) {
        Serial.println("true");
      } else {
        Serial.println("false");
      }
    #endif
    if (validMessage) {
      executeMessage();
      validMessage = false;
    }
    newMessage = false;
  }
}

/*
  Read from the Serial input buffer and save to receivedChars
  The message must start with '<' and end with '>'
*/
void getMessage() {
  char receivedChar;
  static boolean receiveInProgress = false; // Investigate why this need to be static
  static int index = 0;                     // Investigate why this need to be static

  while (Serial.available() > 0) {
    receivedChar = Serial.read();
    if (receiveInProgress) {
      if (receivedChar != endMarker) {
        receivedChars[index] = receivedChar;
        index++;
      } else {
        receivedChars[index] = '\0';
        receiveInProgress = false; // Can this be ignored? The clearSerialInputBuffer below ensures it will exit the while loop
        index = 0;                 // Can this be ignored? The clearSerialInputBuffer below ensures it will exit the while loop
        newMessage = true;
        clearSerialInputBuffer(); // End of the input, clear everything that remain in the buffer
      }
    } else if (receivedChar == startMarker) {
      receiveInProgress = true;
    } else {
      clearSerialInputBuffer(); // Potentially corrupted data, play safe and clear the buffer
    }
  }
}

/*
  Take no input
  Clear the Serial input buffer
*/
void clearSerialInputBuffer() {
  while (Serial.available() > 0) {
    Serial.read();
  }
}

/*
  Take no input
  Determine if the received message is legit
*/
void validateMessage() {
  if (receivedChars[0] == CAN && receivedChars[1] == ',' && (receivedChars[2] == 'r' || receivedChars[2] == 'a' || receivedChars[2] == 'c')) {
    int count = 0;
    for (int i = 0; i < maxNumChars; i++) {
      if (receivedChars[i] == ',') {
        count++;
      }
    }
    if (receivedChars[2] == 'r' && count == 1) {
      // <CAN,r>
      validMessage = true;
    } else if (receivedChars[2] == 'a' && count == 3 && (receivedChars[4] == '0' || receivedChars[4] == '1') && (receivedChars[6] >= '0' && receivedChars[6] <= '9')) {
      // <CAN,a,0,numStep>
      validMessage = true;
    } else if (receivedChars[2] == 'c' && count == 4 && (receivedChars[4] == '0' || receivedChars[4] == '1') && (receivedChars[6] >= '0' && receivedChars[6] <= '9')) {
      // <CAN,c,0,numStep,period>
      validMessage = true;
    } else {
      validMessage = false;
    }
  } else {
    validMessage = false;
  }
}

/*
  Take no input
  Execute commands according to receivedChars
*/
void executeMessage() {
  if (receivedChars[2] == 'r') {
    // <CAN,r>
    // May need to check a few things before return ACK
    // Such as 12V is turned on, etc.
    #if DEBUG == 1
      Serial.print("Mode: ");
      Serial.println("initialization");
    #endif
    receivedChars[4] = '1';
    generateStepPulse(40000, 400);
    receivedChars[4] = '0';
    generateStepPulse(40000, 400);
    Serial.print(startMarker);
    Serial.print(ACK);
    Serial.println(endMarker);
  } else if (receivedChars[2] == 'a') {
    // <CAN,a,0,numStep>
    int indexNull = getFirstIndex(receivedChars, '\0', maxNumChars);
    long numStep = arrayToLong(receivedChars, 6, indexNull);
    #if DEBUG == 1
      Serial.print("Mode: ");
      Serial.print("variable speed");
      Serial.print(", Direction: ");
      if (receivedChars[4] == '0') {
        Serial.print("positive");
      } else {
        Serial.print("negative");
      }
      Serial.print(", Number of steps: ");
      Serial.println(numStep);
    #endif
    if (receivedChars[4] == '1') {
      if (numStep <= 40000L) {
        generateStepPulse(2L * numStep);
        receivedChars[4] = '0';
        generateStepPulse(numStep);
      } else {
        generateStepPulse(numStep + 40000L);
        receivedChars[4] = '0';
        generateStepPulse(40000L);
      }
    } else if (receivedChars[4] == '0') {
      generateStepPulse(numStep);
    }
    Serial.print(startMarker);
    Serial.print(ACK);
    Serial.println(endMarker);
  } else if (receivedChars[2] == 'c') {
    // <CAN,c,0,numStep,period>
    int indexComma = getLastIndex(receivedChars, ',', maxNumChars);
    int indexNull = getFirstIndex(receivedChars, '\0', maxNumChars);
    long numStep = arrayToLong(receivedChars, 6, indexComma);
    long period = arrayToInt(receivedChars, indexComma + 1, indexNull);
    #if DEBUG == 1
      Serial.print("Mode: ");
      Serial.print("constant speed");
      Serial.print(", Direction: ");
      if (receivedChars[4] == '0') {
        Serial.print("positive");
      } else {
        Serial.print("negative");
      }
      Serial.print(", Number of steps: ");
      Serial.print(numStep);
      Serial.print(", Period: ");
      Serial.println(period);
    #endif
    if (receivedChars[4] == '1') {
      if (numStep <= 40000L) {
        generateStepPulse(2L * numStep, period);
        receivedChars[4] = '0';
        generateStepPulse(numStep, period);
      } else {
        generateStepPulse(numStep + 40000L, period);
        receivedChars[4] = '0';
        generateStepPulse(40000L, period);
      }
    } else if (receivedChars[4] == '0') {
      generateStepPulse(numStep, period);
    }
    Serial.print(startMarker);
    Serial.print(ACK);
    Serial.println(endMarker);
  }
}

/*
  Take the number of steps as input
  Generate step pulses using the acceleration curve
*/
void generateStepPulse(long numStep) {
  #if DEBUG == 1
    Serial.print("  - Mode: ");
    Serial.print("variable speed");
    Serial.print(", Direction: ");
    if (receivedChars[4] == '0') {
      Serial.print("positive");
    } else {
      Serial.print("negative");
    }
    Serial.print(", Number of steps: ");
    Serial.println(numStep);
  #endif

  // Set direction of DRV8825
  if (receivedChars[4] == '0') {
    digitalWrite(dirPin, LOW);
  } else if (receivedChars[4] == '1') {
    digitalWrite(dirPin, HIGH);
  }

  // Initialize various variables used in the algorithm
  int increment = -1;
  boolean updatePeriod = true;
  long stepCount = 0;
  long constCount = 0;
  int accelCount = increment;
  int indexCount = 0;
  int updateCount = 0;
  double period = 427.0;
  double stepSize = 4.0/3.0;
  int periodInt = 0;
  int offset = 15;
  while (stepCount < numStep) {
    long startTime = micros();
    digitalWrite(stepPin, HIGH);

    // flip direction
    if (stepCount >= numStep/2 && increment == -1) {
      increment = +1;
      indexCount -= 2;
      accelCount = -1 * accelCount - 1;
      if (periodInt == 50) {
        accelCount = 907;
      }
    }

    // update period
    if (updatePeriod) {
      if (increment == -1) {
        period -= stepSize;
      } else if (increment == +1) {
        period += stepSize;
      }
      periodInt = (int)(period + 0.5);
      updateCount -= increment;
      updatePeriod = false;
    }

    // linear portion
    if (increment == -1 && periodInt > 248) {
      updatePeriod = true;
    } else if (increment == +1 && periodInt >= 248) {
      updatePeriod = true;
    }

    // constant portion
    else if (periodInt <= 50) {
      constCount -= increment;
      if (constCount == 0) {
        updatePeriod = true;
        indexCount--;
      }
    }

    // exponential portion
    else {
      if (accelCount == increment) {
        accelCount = increment * count[indexCount];
        updatePeriod = true;
        indexCount -= increment;
      }
      accelCount -= increment;
    }

    stepCount++;
    delayMicroseconds((startTime + periodInt - micros() - offset) / 2);
    digitalWrite(stepPin, LOW);
    delayMicroseconds((periodInt - offset) / 2);
  }
}

/*
  Take the number of steps and the fixed period as input
  Generate step pulses using the fixed period specified
*/
void generateStepPulse(long numStep, int period) {
  #if DEBUG == 1
    Serial.print("  - Mode: ");
    Serial.print("constant speed");
    Serial.print(", Direction: ");
    if (receivedChars[4] == '0') {
      Serial.print("positive");
    } else {
      Serial.print("negative");
    }
    Serial.print(", Number of steps: ");
    Serial.print(numStep);
    Serial.print(", Period: ");
    Serial.println(period);
  #endif

  // Set direction of DRV8825
  if (receivedChars[4] == '0') {
    digitalWrite(dirPin, LOW);
  } else if (receivedChars[4] == '1') {
    digitalWrite(dirPin, HIGH);
  }

  long stepCount = 0;
  int offset = 10;
  while (stepCount < numStep) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds((period - offset) / 2);
    digitalWrite(stepPin, LOW);
    delayMicroseconds((period - offset) / 2);
    stepCount++;
  }
}

/*
  Take a character array, its length and a target character as input
  Return the first index of the target character in the array
  Return -1 if the target character is not found in the array
*/
int getFirstIndex(char input[], char target, int inputLength) {
  int i = 0;
  while (input[i] != target && i < inputLength) {
    i++;
  }
  return i;
}

/*
  Take a character array, its length and a target character as input
  Return the last index of the target character in the array
  Return -1 if the target character is not found in the array
*/
int getLastIndex(char input[], char target, int inputLength) {
  int i = inputLength - 1;
  while (input[i] != target && i >= 0) {
    i--;
  }
  return i;
}

/*
  Take a character array and two indexes a and b as input
  The two indexes define a subarray [a, b)
  Return the converted long from the subarray
*/
long arrayToLong(char input[], int a, int b) {
  char tmp[b - a + 1];
  tmp[b - a] = '\0';
  for (int i = a; i < b; i++) {
    tmp[i - a] = input[i];
  }
  return atol(tmp);
}

/*
  Take a character array and two indexes a and b as input
  The two indexes define a subarray [a, b)
  Return the converted int from the subarray
*/
int arrayToInt(char input[], int a, int b) {
  char tmp[b - a + 1];
  tmp[b - a] = '\0';
  for (int i = a; i < b; i++) {
    tmp[i - a] = input[i];
  }
  return atoi(tmp);
}

# COBOL/CICS Hangman Game

## 🚀 Project Summary

A COBOL/CICS-based interactive Hangman game built on a mainframe environment, showing how user interactions are handled step by step in a CICS application, along with DB2 integration and BMS-driven screen handling.

The application was presented during IBM Z Day, showcasing real-time interaction and transaction-based processing in a CICS environment.

---

## 🎯 What this project demonstrates

- Building interactive applications in a CICS environment  
- Handling user input step by step across multiple CICS calls  
- Integrating COBOL with DB2 using embedded SQL  
- Designing terminal UIs using BMS maps  
- Managing game logic and validation in a transactional system  

---

## 📸 Demo

![Demo](images/demo.png)

---

## ⚙️ Technologies Used

- COBOL
- CICS (Customer Information Control System)
- BMS Maps (Basic Mapping Support for screen handling)
- DB2
- SQL (embedded in COBOL)

---

## 🔄 Application Flow

1. User starts the application (PF2)
2. A random word is retrieved from DB2
3. The user inputs guesses via the terminal
4. The application updates the UI dynamically
5. Game ends on win or loss condition

---

## 💻 Code Highlights

### CICS Transaction Handling
```cobol
EVALUATE TRUE
  WHEN EIBAID = DFHENTER
  WHEN EIBAID = DFHPF2
```

### DB2 Integration
```cobol
EXEC SQL
  SELECT WORD
  INTO :WORD
  FROM USER11.WORDSDB2
END-EXEC
```

### Iterative Input Processing

This logic validates user input, checks if the guessed character exists in the word, and updates both the UI and internal state.

```cobol
MOVE 0 TO WS-CHAR-COUNT
INSPECT WORD TALLYING WS-CHAR-COUNT FOR ALL INPUTI

IF WS-CHAR-COUNT = 0 AND INPUTI IS ALPHABETIC
   MOVE 'WRONG CHARACTER!' TO MSG1O
   ADD 1 TO WS-COUNTER1
ELSE
   ADD 1 TO WS-COUNTER2
   PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > 10
      IF INPUTI = WORD(WS-POS:1)
         EVALUATE WS-POS
            WHEN 1  MOVE INPUTI TO CHAR1O WS-GUESS(1:1)
            WHEN 2  MOVE INPUTI TO CHAR2O WS-GUESS(2:1)
            WHEN 3  MOVE INPUTI TO CHAR3O WS-GUESS(3:1)
            WHEN 4  MOVE INPUTI TO CHAR4O WS-GUESS(4:1)
            WHEN 5  MOVE INPUTI TO CHAR5O WS-GUESS(5:1)
            WHEN 6  MOVE INPUTI TO CHAR6O WS-GUESS(6:1)
            WHEN 7  MOVE INPUTI TO CHAR7O WS-GUESS(7:1)
            WHEN 8  MOVE INPUTI TO CHAR8O WS-GUESS(8:1)
            WHEN 9  MOVE INPUTI TO CHAR9O WS-GUESS(9:1)
            WHEN 10 MOVE INPUTI TO CHAR10O WS-GUESS(10:1)
         END-EVALUATE
      END-IF
   END-PERFORM
END-IF
```

---

## 🖥️ BMS Maps

The project includes a full BMS mapset (`WORDS.bms`) used to define the terminal UI and user interaction.

Below is a simplified excerpt showing the mapset structure and key fields:

```cobol
WORDS    DFHMSD TYPE=&SYSPARM,
               MODE=INOUT,
               CTRL=FREEKB,
               LANG=COBOL,
               DSATTS=(COLOR,HILIGHT),
               MAPATTS=(COLOR,HILIGHT),
               STORAGE=AUTO

HOMESCR  DFHMDI SIZE=(24,80)

DFHMDF POS=(05,35),
       LENGTH=09,
       ATTRB=PROT,
       COLOR=RED,
       INITIAL='HANG MAN!'

F2START  DFHMDF POS=(07,30),
       LENGTH=26,
       ATTRB=PROT,
       COLOR=RED,
       INITIAL='PRESS F2 TO START!'

INPUT   DFHMDF POS=(15,39),
       LENGTH=1,
       ATTRB=(UNPROT,IC,FSET),
       PICIN='X(01)',
       PICOUT='X(01)',
       COLOR=GREEN
```

The BMS maps define:
- Screen layout and positioning  
- Protected vs unprotected input fields  
- Visual elements such as the hangman drawing  
- User interaction via keyboard input  

These maps are used together with CICS `SEND` and `RECEIVE` to dynamically update the UI during gameplay.

---

## 🧩 Notes

The application demonstrates how COBOL programs interact with BMS maps to create structured terminal interfaces, where field attributes (e.g. PROT, UNPROT) control user input and screen behavior.

---

## 📌 Purpose

This project was developed to gain hands-on experience with COBOL, CICS, DB2, and BMS, focusing on how interactive systems are implemented in a transactional mainframe environment.

## 🚧 Challenges & Learnings

- Understanding how CICS handles program flow across multiple executions was initially challenging, especially how each user interaction triggers a new program call.

- Managing state between interactions required learning how COMMAREA is used to persist data across transactions.

- Working with BMS maps provided insight into how terminal UIs are built, including how field attributes (PROT, UNPROT, FSET) control user input and screen behavior.

- Integrating COBOL with DB2 using embedded SQL helped me understand how mainframe applications interact with relational databases.

- Structuring the application logic into clear sections (input handling, validation, game logic) improved readability and maintainability.

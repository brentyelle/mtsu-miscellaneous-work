{-  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
AUTHOR:     Brent Yelle
DATE:       April 17, 2023
CLASS:      Theory of Programming Languages
LANGUAGE:   Haskell
ASSIGNMENT: Project 2

    This function allows the user to choose a text file and read out student data from it.
    After prompting the user and loading the data from the text file, the program then lets the user choose two students (identified by Student ID) to have their data printed individually.
    After the two students' data is printed, the program will then print out the data for *all* students in the class, and finally the class average and class maximum for each grade.

    The text file containing the data must be space-separated, and each line must contain the following in order:
        Student ID, CLA Grade, OLA Grade, Quiz Grade, Exam Grade, Final Exam Grade
    It is also assumed that the text file's first line is a header line, not a data line.

    All data in the text file is assumed to be in String format (Student ID) or in Integer format (all other data).
    This program is also able to take the numerical data and generate an associated letter grade (a string) to go with it, which is printed as part of a student's data.

    Students are implemented as 7-tuples, which essentially function as Haskell's version of structs.
    Rosters are implemented as associative maps (from the Data.Map package) that allow for binary searching, having O(log n) time complexity for lookup.
    (Under the hood, they are sorted lists of 2-tuples of the form (key, value), where in this case a "key" is a Student ID string and a "value" is a Student 7-tuple.)
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  -}

import Prelude hiding (lookup)                                              --package "base":       overriding this function because we want to import Data.Map's "lookup" instead
import System.IO ( openFile, IOMode(ReadMode), hFlush, stdout )             --package "base":       standard I/O: general-use
import Text.Printf ( printf )                                               --package "base":       standard I/O: lets us align text nicely
import Data.Maybe (isNothing)                                               --package "base":       takes care of "Maybe"-ness
import System.IO.Utils ( hGetLines )                                        --package "MissingH":   to read in the file as an array of lines (i.e. an array of strings)
import Data.Map (Map, singleton, insert, lookup, elems)                     --package "containers": associative map typeclass & some related functions

{-  ==============================================
    MAIN:       The main program that is run when the executable is called.
=============================================== -}
main :: IO ()
main = do
    -- prompt the user for the filename to read
    putStr "Enter name of data file that contains the records: "
    hFlush stdout                                               --flush stdout buffer to ensure prompt is printed before grabbing user input
    filename <- getLine                                         --grab user input from stdin
    -- read from the file
    putStrLn ("\nAttempting to fetch info from file \"" ++ filename ++ "\"...")
    hFlush stdout                                               --ensure the "Fetching..." text prints now, just in case the wait is long
    fileHandle <- openFile filename ReadMode                    --open file in read mode
    fileLines <- hGetLines fileHandle                           --convert file into a list of strings, one for each line of text
    let studentList = map studentConstructor (tail fileLines)   --list of Student-type values; we use "tail" to ignore the first line's header text  ("studentConstructor" is defined below)
    let studentKeys = map studentID studentList                 --grab C-number (student ID#) of each student to be the keys
    let roster   = rosterConstructor studentKeys studentList    --create a Roster-type Associative Map "object" between the keys & values ("rosterConstructor" is defined below)
    putStrLn "Information fetched successfully!"                --if we reached this point, then we've successfully created a map!
    -- prompt the user for which C# to look for (1)
    putStr "\nEnter the C# of the 1st student whose info you want to see: "
    hFlush stdout
    cNumber1 <- getLine                                         --grab user input from stdin
    printThisStudent $ rosterGetStudent cNumber1 roster         --the $ operator lets me avoid putting parentheses around (lookup cNumber1 roster)
    -- prompt the user for which C# to look for (2)
    putStr "\nEnter the C# of the 2nd student whose info you want to see: "
    hFlush stdout                                               --ensure we print before prompt
    cNumber2 <- getLine                                         --grab user input from stdin
    printThisStudent $ rosterGetStudent cNumber2 roster
    --pause to let the student see stuff
    putStr "\nSearches finished. Press Enter to see the whole class's grades & statistics... "
    hFlush stdout                                               --ensure we print before prompt
    _ <- getLine                                                --wait for an Enter from the keyboard (discarding whatever is input)
    --show details for the whole class
    printRoster roster                                          --print details of the whole roster (defined below)
    --end of main
    return ()

{-  ==============================================
    PRINT FUNCTIONS:     Sub-programs that are called for I/O during Main.
=============================================== -}

-- This function takes a "Maybe Student" type from "rosterGetStudent" (an alias of "lookup"), which indicates something that may or not be an existent object.
-- If it's actually Nothing, then there was no matching student found, so we print an apology message to the user.
-- If it is a real Student ("Just Student"), then we grab that student's information and print it.
printThisStudent :: Maybe Student -> IO ()
printThisStudent stu
    | isNothing stu    = do
        putStrLn "Sorry, no such student ID was found in the records!"
        hFlush stdout       --ensure the message is printed
        return ()
    | otherwise   = do
        let Just (id, cla, ola, quiz, exam, final, letter) = stu        --grab the details from the tuple
        putStrLn "=========STUDENT DETAILS========="
        putStrLn ("                C#: " ++ id)
        putStrLn ("         CLA Grade: " ++ show cla)                   --"show" converts a Numeric-type value to a printable string
        putStrLn ("         OLA Grade: " ++ show ola)
        putStrLn ("        Quiz Grade: " ++ show quiz)
        putStrLn ("        Exam Grade: " ++ show exam)
        putStrLn ("  Final Exam Grade: " ++ show final)
        putStrLn ("      Letter Grade: " ++ letter)
        hFlush stdout       --ensure the message is printed
        return ()

-- This function takes a whole Roster of students and prints the header for a large table of all the students' grades, then calls "printAllStudents" to fill the table.
-- It also prints all the statistical information (averages & maxima) for all of the grades that the students have.
printRoster :: Roster -> IO ()
printRoster rost = do
    -- print all students' information
    putStrLn "\n==========CLASS DETAILS=========="
    printf "%10s" "User ID   "
    printf "%7s"  "CLA    "
    printf "%7s"  "OLA    "
    printf "%7s"  "Quiz   "
    printf "%11s" "Exam       "
    printf "%13s" "Final Exam   "
    printf "%13s" "Letter Grade\n"
    putStrLn "--------|------|------|------|----------|------------|--------------"
    hFlush stdout
    printAllStudents (elems rost)
    -- print class averages
    printf "%-12s" " average"
    printf "%4.1f   " (rosterClassAvg studentCLA rost)
    printf "%4.1f   " (rosterClassAvg studentOLA rost)
    printf "%4.1f   " (rosterClassAvg studentQuiz rost)
    printf "%4.1f       " (rosterClassAvg studentExam rost)
    printf "%4.1f         " (rosterClassAvg studentFinal rost)
    printf "\n"
    -- print class maxima
    printf "%-10s" " maximum"
    printf "%4i   " (rosterClassMax studentCLA rost)
    printf "%4i   " (rosterClassMax studentOLA rost)
    printf "%4i   " (rosterClassMax studentQuiz rost)
    printf "%4i       " (rosterClassMax studentExam rost)
    printf "%4i         " (rosterClassMax studentFinal rost)
    putStrLn ""
    hFlush stdout
    return ()

-- Fills the table created by "printRoster" with all the students' details.
printAllStudents :: [Student] -> IO ()
printAllStudents [stu] = do     --base case
    let (id, cla, ola, quiz, exam, final, letter) = stu
    printf "%8s    " id
    printf "%2i     " cla
    printf "%2i     " ola
    printf "%2i     " quiz
    printf "%2i         " exam
    printf "%2i           " final
    printf "%s\n" letter
    hFlush stdout
    return ()
printAllStudents (s:ss) = do    --recursive case
    printAllStudents [s]    --do first element
    printAllStudents ss     --then the rest of the elements recursively
    return ()

{-  ==============================================
    Type Aliases, for clarity in later declarations.
=============================================== -}
type StudentID   = String
type CLAGrade    = Int
type OLAGrade    = Int
type QuizGrade   = Int
type ExamGrade   = Int
type FinalGrade  = Int
type LetterGrade = String

{-  ==============================================
    "Class" Declarations
=============================================== -}

-- Student "Class" Declaration: Students are defined as 7-tuples of all their pertinent information.
type Student = (StudentID, CLAGrade, OLAGrade, QuizGrade, ExamGrade, FinalGrade, LetterGrade)
-- Student "Constructor":
studentConstructor :: String -> Student
studentConstructor str =
    let [sid, cla_str, ola_str, quiz_str, exam_str, final_str] = words str                                      -- splits into different substrings based on original ' ' separators
        [cla, ola, quiz, exam, final] = stringListToIntList [cla_str, ola_str, quiz_str, exam_str, final_str]   -- stringListToIntList is defined below
    in (sid, cla, ola, quiz, exam, final, getLetterGrade cla ola quiz exam final)                               -- getLetterGrade is defined below

-- Roster "Class" Declaration:
type Roster = Map StudentID Student
-- Roster "Constructor": Converts a list of Student IDs and a list of Students into a Map with O(log n) search complexity.
rosterConstructor :: [StudentID] -> [Student] -> Roster
rosterConstructor [id] [stu] =            singleton id stu                                  --base case (creates a map with 1 key and 1 value)
rosterConstructor (id:idL) (stu:stuL) =   insert id stu (rosterConstructor idL stuL)        --recursive (adds each key & value recursively)

{-  ==============================================
    "Constructor" Helper Functions
=============================================== -}

-- Takes care of getting the proper string for the letter grade.
getLetterGrade :: CLAGrade -> OLAGrade -> QuizGrade -> ExamGrade -> FinalGrade -> String
getLetterGrade cla ola quiz exam final
    | g >= 90     = "A "
    | g >= 87     = "B+"
    | g >= 83     = "B "
    | g >= 80     = "B-"
    | g >= 77     = "C+"
    | g >= 73     = "C "
    | g >= 70     = "C-"
    | g >= 67     = "D+"
    | g >= 63     = "D "
    | g >= 60     = "D-"
    | otherwise   = "F "
    where g = cla + ola + quiz + exam + final

-- Takes a list of strings (containing integers!) and outputs a list of integers.
stringListToIntList :: [String] -> [Int]
stringListToIntList = map read

{-  ==============================================
    Student "Class Methods"
=============================================== -}

--Each of the functions below accesses a different part of the 7-tuple that defines a Student.
studentID :: Student -> StudentID       --String
studentID     (x,_,_,_,_,_,_) = x

studentCLA :: Student -> CLAGrade       --Int
studentCLA    (_,x,_,_,_,_,_) = x

studentOLA :: Student -> OLAGrade       --Int
studentOLA    (_,_,x,_,_,_,_) = x

studentQuiz :: Student -> QuizGrade     --Int
studentQuiz   (_,_,_,x,_,_,_) = x

studentExam :: Student -> ExamGrade     --Int
studentExam   (_,_,_,_,x,_,_) = x

studentFinal :: Student -> FinalGrade   --Int
studentFinal  (_,_,_,_,_,x,_) = x

studentLetter :: Student -> LetterGrade --String
studentLetter (_,_,_,_,_,_,x) = x

-- These two functions take a list of Student-types and a "Class Access" function (see above) and return a single value that represents a statistic of that grade.
-- For example, to get the average CLA score, you would run: studentGetAvg studentCLA studentRoster
studentListGetAvg :: (Student -> Int) -> [Student] -> Float
studentListGetAvg f students = fromIntegral (sum studentGrades) / fromIntegral (length studentGrades)   --fromIntegral converts Int to Float
    where studentGrades = map f students

studentListGetMax :: (Student -> Int) -> [Student] -> Int
studentListGetMax f students = maximum studentGrades
    where studentGrades = map f students

{-  ==============================================
    Roster "Class Methods"
=============================================== -}

-- Takes a student and a roster, and returns a new roster with that student added.
-- Thanks to the implementation of "insert" (in Data.Map), if the key is already in the list, the associated value will simply be updated.
rosterAddStudent :: Student -> Roster -> Roster
rosterAddStudent stu = insert (studentID stu) stu

-- The function rosterAddStudent (defined above) already has all the functionality we need.
rosterChangeStudent :: Student -> Roster -> Roster
rosterChangeStudent = rosterAddStudent

-- The function "lookup" (in Data.Map) already has all the functionality we need.
-- The return type needs to be "Maybe Student" since we aren't guaranteed that the student is in the list.
rosterGetStudent :: StudentID -> Roster -> Maybe Student
rosterGetStudent = lookup

-- Takes a Student "class method" and finds the *maximum* value of those scores among all the students in the Roster.
-- For example, "rosterClassAvg studentFinal myRoster" would yield the average of all the Final Exam grades for all students.
rosterClassAvg :: (Student -> Int) -> Roster -> Float
rosterClassAvg f rost = studentListGetAvg f (elems rost)    --"elems" converts the map's values (Student-types) into a list

-- Takes a Student "class method" and finds the *maximum* value of those scores among all the students in the Roster.
-- For example, "rosterClassMax studentFinal myRoster" would yield the maximum of all the Final Exam grades for all students.
rosterClassMax :: (Student -> Int) -> Roster -> Int
rosterClassMax f rost = studentListGetMax f (elems rost)    --"elems" converts the map's values (Student-types) into a list

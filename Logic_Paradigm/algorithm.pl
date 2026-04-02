%The algorithm
:- consult('c:\\Users\\Acadia Marchand\\CSI2120_ResMatchService\\Logic_Paradigm\\rp.pl').

findall(match(P,[]), program(P,_,_,_), Ms).

% rankInProgram(ResidentID, ProgramID, Rank)
rankInProgram(ID, PID, R):-
    program(PID, _, _, Rs), %finds the program PID and the list of the residents and their ranks in that program
    nth1(R, Rs, ID). %nth1 is 1 based indexing (found in the list section of the prolog documentation)

% leastPreferred(ProgramID, ResidentID, LeastPreferredResidentID, RankOfThisResident)
leastPreferred(PID,[H], H, RankH):- %Base case if the list of resident IDs only contains one id
    rankInProgram(H, PID, RankH).

leastPreferred(PID, [H|T], LPR, RR):-
    rankInProgram(H, PID, RankH), %Checks the rank of the head of the list
    leastPreferred(PID, T, TID, TRank), %Recursively checks the tail of the list and finds the least preferred resident and their rank
    (RankH > TRank -> %Compares the rank of the head and the least preferred resident in the tail, and returns the one with the higher rank (least preffered)
        LPR = H,
        RR = RankH
    ;
        LPR = TID,
        RR = TRank).

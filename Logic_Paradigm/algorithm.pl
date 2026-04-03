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

% matched(ResidentID, ProgramID, MatchSet) - identifies resident has
% been matched
matched(RID,PID,[match(PID,Residents)| _]) :-
    member(RID,Residents), !.
matched(RID,PID,[_| T]) :-
    matched(RID,PID,T).

add(RID,PID,[match(PID,Residents)|T],NMS) :-
    NMS = [match(PID,[RID|Residents])|T].
add(RID,PID,[CMS|T],[CMS|Res]) :-
    add(RID,PID,T,Res).

remove(RID,PID,[match(PID,Residents)|T],[match(PID,NewResidents)|T]):-
    delete(Residents,RID,NewResidents).
remove(RID,PID,[CMS|T],[CMS|Res]) :-
    remove(RID,PID,T,Res).

% offerHelper(ResidentID, ROL, currentMatchSet, newMatchSet)
offerHelper(RID, [], CMS, CMS).
offerHelper(RID, [PID|T],CMS, NMS) :-
    program(PID,_,Capacity,_),
    member(match(PID, ProgResidents),CMS),
    length(ProgResidents, Length),
    offerCheck(RID,[PID|T],CMS,NMS,Length,Capacity,ProgResidents).
offerCheck(RID,[PID|T],CMS,NMS,Length,Capacity,ProgResidents) :-
     Length < Capacity,
     !,
     add(RID,PID,CMS,NMS).
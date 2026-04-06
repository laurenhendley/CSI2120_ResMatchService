%Students:
%Lauren Hendley [lhend093@uottawa.ca, SN: 300405588]
%Acadia Marchand [amarc139@uottawa.ca, SN: 300340641]


%The algorithm
:- consult(rp4000).

%the code from the assignment description that prints displays the solution
%PARAM:ResidentID, ProgramID
writeMatchInfo(ResidentID,ProgramID):-
    resident(ResidentID,name(FN,LN),_),
    program(ProgramID,TT,_,_),write(LN),write(','),
    write(FN),write(','),write(ResidentID),write(','),
    write(ProgramID),write(','),writeln(TT).

%PARAM:Matchset
initialMatches(Ms):-
    findall(match(P,[]), program(P,_,_,_), Ms). %this query produces the initial match set with no matched residents, which is used as the starting point for the algorithm

% Finds the resident's rank in the program
% rankInProgram(ResidentID, ProgramID, Rank)
rankInProgram(ID, PID, R):-
    program(PID, _, _, Rs), %finds the program PID and the list of the residents and their ranks in that program
    nth1(R, Rs, ID). %nth1 is 1 based indexing (found in the list section of the prolog documentation)

% leastPreferred(ProgramID, ResidentID, LeastPreferredResidentID,RankOfThisResident)
leastPreferred(PID,[H], H, RankH):- %Base case if the list of resident IDs only contains one id
    rankInProgram(H, PID, RankH).

%PARAM:ProgramID, list, leastpreferredresident, rank
leastPreferred(PID, [H|T], LPR, RR):-
    rankInProgram(H, PID, RankH), %Checks the rank of the head of the list
    leastPreferred(PID, T, TID, TRank), %recursively checks the tail of the list and finds the least preferred resident and their rank
    (RankH > TRank -> %compares the rank of the head and the least preferred resident in the tail, and returns the one with the higher rank (least preffered)
        LPR = H,
        RR = RankH
    ;
        LPR = TID,
        RR = TRank).

% matched(ResidentID, ProgramID, MatchSet) - identifies resident has
% been matched
matched(RID,PID,[match(PID,Residents)| _]) :- %checks if the resident is in the list of matched residents for the prgram
    member(RID,Residents), !.
matched(RID,PID,[_| T]) :- %if not, then recursively checks the rest of the match set
    matched(RID,PID,T).

%PARAM:residentid,programid, matchset, newmatchset
add(RID,PID,[match(PID,Residents)|T],NMS) :- %adds the resident to the program in the match set
    NMS = [match(PID,[RID|Residents])|T].

%PARAM:residentid, programid, matchset, newmatchset
add(RID,PID,[CMS|T],[CMS|Res]) :- %recursivley goes through the match set until it finds the right program for the resident to be added to
    add(RID,PID,T,Res).

%PARAM:residentid,programid,matchset,newmatchset
remove(RID,PID,[match(PID,Residents)|T],[match(PID,NewResidents)|T]):- %removes the residetn from the program in the match set
    delete(Residents,RID,NewResidents).

%PARAM:residentid,programid,matchset,newmatchset
remove(RID,PID,[CMS|T],[CMS|Res]) :- %recursivley goes through the match set until it finds the right program for the resident to be removed from
    remove(RID,PID,T,Res).

% offerHelper(ResidentID, ROL, currentMatchSet, newMatchSet)
offerHelper(RID, [], CMS, CMS). %Base case if the resident has no more programs to offer to, then we are done and can return the current match set as the new match set
offerHelper(RID, [PID|T],CMS, NMS) :- %Checks the first program in the residents ROL and checks if it can make an offer, if it can returns te new match set, if not then it recursively calls the offer helper function with the rest of the ROL
    program(PID,_,Capacity,_),
    member(match(PID, ProgResidents),CMS),
    length(ProgResidents, Length),
    (offerCheck(RID,[PID|T],CMS,NMS,Length,Capacity,ProgResidents) %if the offer check is succefsul, then we can return the new match set, otherwise we continue and chen the next program
    ;
    offerHelper(RID, T,CMS,NMS)
    ).

% PARAM:residentid,list,matchset,newmatchset,length,capcity,program's
% residents
offerCheck(RID,[PID|T],CMS,NMS,Length,Capacity,ProgResidents) :- %if the program has the capacity for another resident, then we can add the resident to the program and return the new match set
     Length < Capacity,
     !,
     add(RID,PID,CMS,NMS).

% PARAM:residentid,list,matchset,newmatchset,length,capcity,program's
% residents
offerCheck(RID,[PID|T],CMS,NMS,Length,Capacity,ProgResidents) :- %checks if the program si full, if it is then checks if a resident is less preferred than the one making the offer
    Length >= Capacity,
    leastPreferred(PID, ProgResidents, LPR, RankLPR),
    rankInProgram(RID, PID, RankRID),
    RankRID < RankLPR, %if the resident making the offer is more preffered, removes the least preffered one and adds the new resident into the program
    !,
    remove(LPR,PID,CMS,TempCMS),
    add(RID,PID,TempCMS,NMS).

% offer(ResidentID, currentMatchSet, newMatchSet)
offer(RID, CMS, NMS) :- %this find the residents ROL and then call the offer helper function to try to make an offer
    resident(RID, _, ROL),
    offerHelper(RID, ROL, CMS, NMS).


%The algorithm part

%the shapleyHelper function is a recursive function that takes in a list of resident ids, the current match set, and a variable to store the final match set.
%It goes through the list of resident ids and calls the offer function for each resident, it then updates the match set. When all residents have made their offers, the final match set is returned.
shapleyHelper([], CurrentMatches, FinalMatches):-
    FinalMatches = CurrentMatches. %Base case, if there are no more residents to make offers, then we are done and can return the final match set

%PARAM:list,current matches, final matches
shapleyHelper([RID|T], CurrentMatches, FinalMatches):-
    offer(RID, CurrentMatches, NewMatches), %The resident makes an offer and we get the new match set
    shapleyHelper(T, NewMatches, FinalMatches). %We recursively call the helper function with the tail of the resident list and the new match set

%PARAM:all rids, current matches, final matches
stableMatch(RIDs, CurrentMatches, FinalMatches):-
    findall(RID, (member(RID, RIDs), \+ matched(RID, _, CurrentMatches)), UnmatchedRIDs), %Finds all the unmatched residents in the current match set
    (UnmatchedRIDs = [] -> %If there are no unmatched residents, then we are done and can return the final match set
        FinalMatches = CurrentMatches
    ;
        shapleyHelper(UnmatchedRIDs, CurrentMatches, NewMatches),
        (CurrentMatches == NewMatches -> FinalMatches = CurrentMatches
        ;
        stableMatch(RIDs, NewMatches, FinalMatches) %If the match set has changed, then we need to check again for unmatched residents and repeat the process
        )
    ).

gale_shapley:- %the main predicate function that runs the algorithm, connects all the previous functions together to produce the final solution!
    initialMatches(Ms),
    findall(RID, resident(RID, _, _), RIDs), %finds all the resident ids and stores them in a list
    stableMatch(RIDs, Ms, FinalMs),
    forall(%for each resident, we check if they are matched in the final match set, if they are we print their match info, otherwise we print that they are not matched
        resident(RID, name(FN, LN), _),
        (matched(RID, PID, FinalMs) -> writeMatchInfo(RID, PID) %uses the writeMatchInfo function to print the match info for the matched resident
        ;
        write(LN), write(','), write(FN), write(','), write(RID), write(',XXX,NOT_MATCHED'), nl %format: lastname, firstname, residentid, XXX (for program id), NOT_MATCHED
        )
    ),

    %this part is to print the number of unmatched residents and positions
    findall(RID, (resident(RID,_,_), \+ matched(RID, _, FinalMs)), UnmatchedRIDs), %finds all the unmatched residents in the final match set
    length(UnmatchedRIDs, NumUnmatched), %counts the number of unmatched residents
    write('Number of unmatched residents: '), write(NumUnmatched), nl,
    write('Number of positions available: '), write(NumUnmatched), %number of unmatched positions is the same as the number of unmatched residents so reuse the same variable
    !.

// Imports
import java.io.FileReader;
import java.util.HashMap;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.io.BufferedReader;
import java.util.List;

/** Stable matching main file
 * 
 * @author Lauren Hendley [lhend093@uottawa.ca, 300405588]
 * @author Acadia Marchand [amarc139@uottawa.ca, ]
 */
public class StableMatching {
	/** Main method
	 * @param args
	 */
    public static void main(String[] args) {
		try {
			
			GaleShapley gs = new GaleShapley(args[0], args[1]);

			gs.matchResidents();

			
			//Formatting for the output
			System.out.println("lastname, firstname, residentID, programID, name");
			for (Resident residents : gs.residents.values()){
				String programID;
				String programName;

				if (residents.getMP() != null){
					programID = residents.getMP().getID();
					programName = residents.getMP().getName();

					System.out.println(residents.getLastName() + "," + residents.getFirstName() + "," + residents.getId() + "," + programID + "," + programName);
				}
				else{
					programID = "XXX";
					programName = "NOT_MATCHED";
					System.out.println(residents.getLastName() + "," + residents.getFirstName() + "," + residents.getId() + "," + programID + "," + programName);
				}
			}

			//Calculating the unmatched residents and available spots based on the matches and outputs the results.
			int notMatched = 0;
			for (Resident resident : gs.residents.values()){
				if (resident.getMP() == null){
					notMatched++;
				}
			}
			int availableSpots = 0;
			for (Program program : gs.programs.values()){
				availableSpots += program.getQuota() - program.getMatchedResidents().size();
			}

			System.out.println("\nNumber of unmatched residents: " + notMatched);
			System.out.println("Number of available spots in programs: " + availableSpots);
			
			
        } catch (Exception e) {
            System.err.println("Error reading the file: " + e.getMessage());
        }
	}
}
// Imports
import java.io.FileReader;
import java.util.HashMap;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.io.BufferedReader;
import java.util.List;

/** Basic Gale Shapley algorithm class for CSI2120 project
 * 
 * Gale Shapley - stable matching algorithm, finds the most desirable option for each resident 
 * Note: some programs will not have residents, some residents will not have a program
 *       do not test using 50,000 file - it will take a looooooooong time
 * 
 * @author Lauren Hendley [lhend093@uottawa.ca, 300405588]
 * @author Acadia Marchand [amarc139@uottawa.ca, 300340641]
 */
public class GaleShapley {
    // Instatiating variables
    HashMap<Integer, Resident> residents;
    HashMap<String, Program> programs;

    
    /** Reads the residents from the csv file
     * @param filename
     * @throws IOException
     * @throws NumberFormatException
     */
    public void readResidents(String residentsFilename) throws IOException, NumberFormatException {

        String line;
		residents = new HashMap<Integer,Resident>();
		BufferedReader br = new BufferedReader(new FileReader(residentsFilename)); 

		int residentID;
		String firstname;
		String lastname;
		String plist;
		String[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the resident ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				} 
			}
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			residentID= Integer.parseInt(line.substring(0,split));
			split++;

			// extracts the resident firstname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			firstname= line.substring(split,i);
			split= i+1;
			
			// extracts the resident lastname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			lastname= line.substring(split,i);
			split= i+1;		
				
			Resident resident= new Resident(residentID,firstname,lastname);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				} 
			}
			
			// extracts the program list
			plist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			rol = plist.split(delimiter);
			
			resident.setRol(Arrays.asList(rol));
			
			residents.put(residentID,resident);

		}
		br.close();
    }

    /** Reads the programs from the csv file
     * @param filename
     * @throws IOException
     * @throws NumberFormatException
     */
    public void readPrograms(String programsFilename) throws IOException, NumberFormatException {

        String line;
		programs= new HashMap<String,Program>();
		BufferedReader br = new BufferedReader(new FileReader(programsFilename)); 

		String programID;
		String name;
		int quota;
		String rlist;
		int[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the program ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				} 
			}			
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);


			programID= line.substring(0,split);
			split++;

			// extracts the program name
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);
			
			name= line.substring(split,i);
			split= i+1;
			
			// extracts the program quota
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			quota= Integer.parseInt(line.substring(split,i));
			split= i+1;		
				
			Program program= new Program(programID,name,quota);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				} 
			}
			
			// extracts the resident list
			rlist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			String[] rol_string = rlist.split(delimiter);
			rol= new int[rol_string.length];
			for (int j=0; j<rol_string.length; j++) {
				
				rol[j]= Integer.parseInt(rol_string[j]);
			}

            List<Integer> rols = new ArrayList<>();
            for(int val : rol){
                rols.add(val);
            }
			
			program.setRol(rols);

			program.setMatchedResidents(new ArrayList<>()); // initializing matched residents list
			
			programs.put(programID,program);

		}
		br.close();
    }

	/** Matches residents to programs using Gale Shapley algorithm
	 * 
	 */
	public void matchResidents(){
		for (Program program : programs.values()){
			program.setMatchedResidents(new ArrayList<>()); // gives each program an empty matched residents list
		}

		HashMap<Integer, Integer> currentChoice = new HashMap<>(); //keeps track of which program each resident will propose to next
		for (Resident resident : residents.values()) {
			currentChoice.put(resident.getId(), 0); // initialize proposal index for each resident
		}

		boolean matched = false; //flag to indicate if all residents are matched

		while (!matched){ //While the resident have been matched or can't be matched (this is the main loop of the algorithm)
			matched = true;

			for (Resident resident : residents.values()){ //iterate through each resident

				if (resident.getMP() == null){ //if the resident is not yet matched
					
					int choice = currentChoice.get(resident.getId()); //get the index of the program to propose
					
					if (choice < resident.getRol().size()){
						matched = false; //if the resident still has programs to be matched with

						String programID = resident.getRol().get(choice);
						Program program = programs.get(programID);

						currentChoice.put(resident.getId(), choice + 1); //moves to the next choice

						if (program != null){
							int residentRank = -1; //if the program exist it sets the resident rank to -1 because it hasn't been found yet

							for (int i = 0; i < program.getRol().size(); i++){ //finds the rank of the resident in the program ROL
								if (program.getRol().get(i) == resident.getId()){
									residentRank = i;
									break;
								}
							}

							if (residentRank != -1){ //if the resident is in the program ROL
								
								if (program.getMatchedResidents().size() < program.getQuota()){ //makes sure the program has spots left and adds the resident if there is
									resident.setMP(program);
									resident.setMR(residentRank);
									program.getMatchedResidents().add(resident);
								}
								else{
									Resident leastPreffered = program.leastPreferred(); //get the least preferred resident currently matched

									if (residentRank < leastPreffered.getMR()){
										program.getMatchedResidents().remove(leastPreffered); //removes the least preferred resident
										leastPreffered.setMP(null); //unmatches the least preferred resident
										leastPreffered.setMR(-1);

										resident.setMP(program);
										resident.setMR(residentRank);
										program.getMatchedResidents().add(resident);
									}
								}
							}
						}
					}

				}
			}
		}
	}


    /** Gale Shapley algorithm
     * @param residentsFilename
     * @param programsFilename
     * @throws IOException
     * @throws NumberFormatException
     */
    public GaleShapley(String residentsFilename, String programsFilename) throws IOException, NumberFormatException {
		readResidents(residentsFilename);
		readPrograms(programsFilename);
	}
}

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
 * @author Lauren Hendley [lhend093@uottawa.ca], []
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

            br.close();
		}	
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
			
			programs.put(programID,program);

            br.close();
		}	
    }

    
    /** Gale Shapely algorithm
     * @param residentsFilename
     * @param programsFilename
     * @throws IOException
     * @throws NumberFormatException
     */
    public GaleShapley(String residentsFilename, String programsFilename) throws IOException, NumberFormatException {
		readResidents(residentsFilename);
		readPrograms(programsFilename);


	}

    public static void main(String[] args) {
		try {
			
			GaleShapley gs= new GaleShapley(args[0],args[1]);
			
			System.out.println(gs.residents);
			System.out.println(gs.programs);
			
        } catch (Exception e) {
            System.err.println("Error reading the file: " + e.getMessage());
        }
	}
}

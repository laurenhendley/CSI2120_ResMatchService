// Imports
import java.io.FileNotFoundException;
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
    HashMap<Integer, Resident> idToRes = new HashMap<>();
    HashMap<String, Program> idToProg = new HashMap<>();

    
    /** Reads the residents from the csv file
     * @param filename
     */
    public ArrayList<Resident> loadResidents(String filename) throws FileNotFoundException{
        ArrayList<Resident> residents = new ArrayList<>();

        try(BufferedReader buffread = new BufferedReader(new FileReader(filename))){
            String line;

            buffread.readLine();

            while((line = buffread.readLine()) != null){
                String[] attributes = line.split(",");

                if(attributes.length != 4) return null;

                int id = Integer.parseInt(attributes[0].trim());
                String fn = attributes[1].trim();
                String ln = attributes[2].trim();

                String roles = attributes[3].replace("[","").replace("]", "");
                List<String> rol = Arrays.asList(roles.split("\\s*,\\s*"));


                Resident res = new Resident(id, fn, ln, rol);

                if(res != null){
                    residents.add(res);
                }
            }


        } catch(IOException e){
            System.out.println("Error caught: " + e.getMessage());
        }

        return residents;
    }

    /** Reads the programs from the csv file
     * @param filename
     */
    public ArrayList<Program> loadPrograms(String filename) throws FileNotFoundException{
        ArrayList<Program> programs = new ArrayList<>();

        try(BufferedReader buffread = new BufferedReader(new FileReader(filename))){
            String line;

            buffread.readLine();

            while((line = buffread.readLine()) != null){
                String[] attributes = line.split(",");

                if(attributes.length != 4) return null;

                String id = attributes[0].trim();
                String name = attributes[1].trim();
                int quota = Integer.parseInt(attributes[2].trim());

                String roles = attributes[3].replace("[","").replace("]", "");
                String[] r_parts = roles.split("\\s*,\\s*");
                List<Integer> rol = new ArrayList<>();

                for(String r : r_parts){
                    rol.add(Integer.parseInt(r));
                }


                Program res = new Program(id,quota,name,rol,null);

                if(res != null){
                    programs.add(res);
                }
            }


        } catch(IOException e){
            System.out.println("Error caught: " + e.getMessage());
        }

        return programs;
    }
}

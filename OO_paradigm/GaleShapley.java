// Imports
import java.util.HashMap;

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
    public void loadResidents(String filename){

    }


    /** Reads the programs from the csv file
     * @param filename
     */
    public void loadPrograms(String filename){


    }


}

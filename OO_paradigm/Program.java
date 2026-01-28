// Imports
import java.util.List;

/** Basic Program class for CSI2120 project
 * @author Lauren Hendley [lhend093@uottawa.ca], []
 */
public class Program {
    // Instatiating variables
    private String id;
    private String name;
    private int quota;
    private List<Integer> rol;
    private List<Resident> matchedResidents; 

    /** Program constructor with just id and name and quota
     * @param id
     * @param name
     * @param quota
     */
    public Program(String id, String name, int quota){
        this.id = id;
        this.name = name;
        this.quota = quota;
    }

    /** Full program constructor
     * @param id
     * @param quota
     * @param name
     * @param rol
     * @param matchedResidents
     */
    public Program(String id, int quota, String name, List<Integer> rol, List<Resident> matchedResidents){
        this.id = id;
        this.name = name;
        this.quota = quota;
        this.rol = rol;
        this.matchedResidents = matchedResidents;
    }



    // HELPER METHODS


    /** Returns true if the resident is included in the ROL of this program
     * @param residentId
     * @return t/f
     */
    public boolean member(int residentId){
        for(Resident r : matchedResidents){
            if(r.getId() == residentId){
                return true;
            }
        }
        return false;
    }

    /** Returns the rank of the resident in the program ROL (or -1 if the resident is not in the list)
     * @param residentId
     * @return rank
     */
    public int rank(int residentId){
        for(Resident r : matchedResidents){
            if(r.getId() == residentId){
                return r.getMR();
            }
        }
        return -1;
    }

    /** Returns the reference to the matched resident instance having the highest rank in the program ROL (the least preferred one)
     * @return maxRes
     */
    public Resident leastPreferred(){
        int maxMR = 0;
        Resident maxRes = null;

        for(Resident r: matchedResidents){
            maxMR = Math.max(r.getMR(), maxMR);
            if(Math.max(r.getMR(), maxMR) == r.getMR()){
                maxRes = r;
            }
        }

        return maxRes;
    }


    /** Add the resident to the match list of this program if the program has not reached its quota or if this resident is preferred over some of the currently matched residents
     * @param r
     */
    public void addResident(Resident r){
        if(matchedResidents.size() != quota){
            matchedResidents.add(r);
        }
        else{
            Resident tmpR = leastPreferred();
            matchedResidents.remove(tmpR);
            matchedResidents.add(r);
        }
    }





    // GETTERS AND SETTERS 


    // ID

    /** @return id */
    public String getID(){ return id; }
    /** @param id */
    public void setID(String id){ this.id = id; }


    // Name

    /** @return name */
    public String getName(){ return name; }
    /** @param name */
    public void setName(String name){ this.name = name; }


    // Quota

    /** @return quota */
    public int getQuota(){ return quota; }
    /** @param quota */
    public void setQuota(int quota){ this.quota = quota; }


    // Rol

    /** @return rol */
    public List<Integer> getRol(){ return rol; }
    /** @param rol */
    public void setRol(List<Integer> rol){ this.rol = rol; }


    // matchedResidents

    /** @return matchedResidents */
    public List<Resident> getMatchedResidents(){ return matchedResidents; }
    /** @param matchedResident */
    public void setMatchedResidents(List<Resident> matchedResidents){ this.matchedResidents = matchedResidents; }
}

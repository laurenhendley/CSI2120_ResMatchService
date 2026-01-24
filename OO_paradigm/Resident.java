// Imports
import java.util.List;

/** Basic Resident class for CSI2120 project
 * @author Lauren Hendley [lhend093@uottawa.ca], []
 */
class Resident {
    // Instatiating variables
    private int id;
    private String firstname;
    private String lastname;
    private List<String> rol;
    private Program matchedProgram;
    private int matchedRank;

    /** Full resident constructor
     * @param id
     * @param fn
     * @param ln
     * @param rol
     * @param mp
     * @param matchedRank
     */
    public Resident(int id, String fn, String ln, List<String> rol, Program mp, int matchedRank){
        this.id = id;
        this.firstname = fn;
        this.lastname = ln;
        this.rol = rol;
        this.matchedProgram = mp;
        this.matchedRank = matchedRank;
    }

    /** Resident constructor not including any matchings (both null)
     * @param id
     * @param fn
     * @param ln
     * @param rol
     */
    public Resident(int id, String fn, String ln, List<String> rol){
        this.id = id;
        this.firstname = fn;
        this.lastname = ln;
        this.rol = rol;
        this.matchedProgram = null;
        this.matchedRank = -1;
    }





    // GETTERS AND SETTERS 


    // ID

    /** @return id */
    public int getId(){ return id; }
    /** @param id */
    public void setId( int id ){ this.id = id; }


    // Firstname

    /** @return firstname */
    public String getFirstName(){ return firstname; }
    /** @param firstname */
    public void setFirstName(String firstname){ this.firstname = firstname; }


    // Lastname

    /** @return lastname */
    public String getLastName(){ return lastname; }
    /** @param lastname */
    public void set(String lastname){ this.lastname = lastname; }


    // Rol

    /** @return rol */
    public List<String> getRol(){ return rol; }
    /** @param rol */
    public void setRol(List<String> rol){ this.rol = rol; }


    // MatchedProgram

    /** @return matchedProgram */
    public Program getMP(){ return matchedProgram; }
    /** @param matchedProgram */
    public void setMP(Program matchedProgram){ this.matchedProgram = matchedProgram; }


    // MatchedRank

    /** @return matchedRank */
    public int getMR(){ return matchedRank; }
    /** @param matchedRank */
    public void setMR(int matchedRank){ this.matchedRank = matchedRank; }
}
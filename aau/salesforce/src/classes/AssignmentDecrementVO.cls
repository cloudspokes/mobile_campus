/**
 * Value object to keep track of assignment counters per term per user
 */
public class AssignmentDecrementVO {
	
	public Double activeCounter = 0;
	public Double inquiryCounter = 0;
	
	public Id userid;
	public String termName;

}
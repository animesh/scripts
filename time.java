import java.util.TimeZone;

/**
 *
 * @author sharma.animesh@gmail.com
 */
public class time {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        long time1= (System.currentTimeMillis());
                System.out.println("TimeC"+time1);
        long timeDiff= (System.currentTimeMillis()-System.currentTimeMillis()%(1000 * 60 * 60));
                System.out.println("TimeD"+timeDiff);
        long time2= (System.currentTimeMillis()%(1000 * 60 * 60));
                System.out.println("TimeR"+time2);
        float time4= (timeDiff/(1000* 60 * 60));
                System.out.println("Time"+time4);
        long time5= (timeDiff + (1000* 60 * 60));
                System.out.println("TimeQ"+time5);
        float time6= (timeDiff + (1000* 60 * 60))/(1000* 60 * 60);
                System.out.println("TimeN"+time6);
        long time7= ((System.currentTimeMillis()+3600000)%(1000 * 60 * 60)+time1);
                System.out.println("TimeNN"+time7);
                int h = (int) ((System.currentTimeMillis() / 1000) / 3600);
int m = (int) (((System.currentTimeMillis() / 1000) / 60) % 60);
int s = (int) ((System.currentTimeMillis() / 1000) % 60);
                System.out.println("h"+h+"m"+m+"s"+s);
TimeZone tz = TimeZone.getDefault();
int offsetFromUtc = tz.getOffset(0);
System.out.println("TimeZone   "+tz.getDisplayName(false, TimeZone.SHORT)+" Timezon id :: " +tz.getID() + "OffSet"+offsetFromUtc);
                int h2 = (int) ((offsetFromUtc / 1000) / 3600);
int m2 = (int) (((offsetFromUtc / 1000) / 60) % 60);
int s2 = (int) ((offsetFromUtc / 1000) % 60);
                System.out.println("h"+h2+"m"+m2+"s"+s2);

    }
}

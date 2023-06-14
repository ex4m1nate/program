import java.io.*;

public class Training{
    public static void main(String[] args) throws IOException{
        BufferedReader br = new BufferedReader(
            new InputStreamReader( System.in ) );

        String s = br.readLine();
        System.out.println( s );

        int[] result = new int[3];

        result[0] = 75;
        result[1] = 88;
        result[2] = 82;

        for (int i = 0 ; i < 3 ; i++){
            System.out.println(result[i]);
        }

        int num = 8;
        int array[] = {10, 4};

        System.out.println("num = " + num);
        System.out.println("array[0] = " + array[0]);

        change(num, array);

        System.out.println("num = " + num);
        System.out.println("array[0] = " + array[0]);
    }

    private static void change(int num, int array[]){
        num = 5;
        array[0] = 12;
    }
}

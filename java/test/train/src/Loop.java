public class Loop {
    public static void main(String[] args){
        int sum = 0;
    
        for (int i = 1; i <= 5; i++){
            System.out.println(i);
            sum += i;
        }
        System.out.println("合計=" + sum);

        int over = 0;

        for (int i = 1; ; i++){
            over += i;
            if (over > 65535){
                break;
            }
        }
        System.out.println(over);

        int a = 1;

        for (;;){
            System.out.println(a);
            a *= 3;
            if (a > 100){
                break;
            }
        }
        System.out.println(a);
    }
}

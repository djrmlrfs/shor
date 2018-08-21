using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;

namespace Quantum.Shor
{
    class Driver
    {
        static int gcd(int a, int b)
        {
            if (b == 0) return a;
            else return gcd(b,a%b);
        }
        static int pow(int a, int r, int N)
        {
            int rr = r, ans = 1, tmp = a;
            while (rr > 0)
            {
                if (rr % 2 == 1) ans = ans*tmp%N;
                tmp = tmp*tmp%N;    rr = rr/2;
            }
            return ans;
        }
        static int Orderf(int x, int N, int t, int L)
        {
            using (var sim = new QuantumSimulator())
            {
                int cnt = 0;
                int[] frac = new int[2*t];
                var tmp = QOF.Run(sim,x,N,t,L).Result;
                while(true)
                {
                    tmp = 1.0/tmp;
                    frac[cnt] = (int)Math.Floor(tmp);
                    tmp = tmp-frac[cnt++];
                    if (Math.Abs(tmp) < 1e-6) break;                
                }
                int nmr = 0, dnm = 1, temp;
                for (int i = cnt-1; i >= 0; i--)
                {
                    temp = nmr+dnm*frac[i];
                    nmr = dnm;  dnm = temp;
                }
                return dnm;
            }
        }

        static void Main(string[] args)
        {
            Random ran = new Random();
            bool[] fail = new bool[128];
            int[] need = new int[2];
            need[0] = 15;   need[1] = 21;
            for (int zz = 0; zz < 2; ++zz)
            {
                N = need[zz];
                for (int i = 2; i < N; ++i) fail[i] = false;
                int tot = 0;
                Console.WriteLine("Factorize "+N+":");
                while (tot+2 < N)
                {
                    int x = ran.Next(2,N);
                    if (fail[x]) continue;
                    ++tot;  fail[x] = true;
                    if (gcd(N,x) != 1)
                    {
                        Console.WriteLine("rand a factor:"+x+" in "+tot+" times");
                        continue;
                    }
                    int r = Orderf(x,N,5,7);
                    if (r >= N)
                    {
                        --tot;
                        fail[x] = false;
                        continue;
                    }
                    int c = pow(x,r,N);
                    if (c != 1)
                    {
                        tot--;
                        fail[x] = false;
                        continue;
                    }
                    if (r%2 != 0) continue;
                    if ((pow(x,r/2,N)+1)%N == 0)    continue;

                    int p = gcd(pow(x,r/2,N)-1,N);
                    int q = gcd(pow(x,r/2,N)+1,N);
                    Console.WriteLine(N+" = "+p+" * "+q);
                    break;
                }
                Console.WriteLine("We tried "+tot+" times\n");
            }
            Console.ReadKey();
        }
    }
}
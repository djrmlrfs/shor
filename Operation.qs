namespace Quantum.Shor
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
	operation Set(desired:Result, q1:Qubit):()
    {
        body
        {
            let current = M(q1);
            if (desired != current)
            {
                X(q1);
            }
        }
    }
    operation Ux(x:Int, N:Int, y:Qubit[]):()
	{
		body
		{
			let TMP = LittleEndian(y);
			ModularMultiplyByConstantLE(x,N,TMP);
		}
		controlled auto
	}
	operation QFT(q:Qubit[]):()
    {
        body
        {
			mutable n = Length(q);
			mutable pow = new Int [n+1];
			set pow[0] = 1;
			for (i in 1 .. n)
			{
				set pow[i] = 2*pow[i-1]; 
			}
            for (i in 0 .. n-1)
			{
				H(q[i]);
				for (j in i+1 .. n-1)
				{
					(controlled R1)([q[j]],(2*PI()/pow[j-i+1],q[i));
				}
			}
			for (i in 0 .. (n-1)/2)
			{
				SWAP(q[i],q[n-1-i]);
			}
        }
		adjoint
		{
			mutable n = Length(q);
			mutable pow = new Int [n+1];
			set pow[0] = 1;
			for (i in 1 .. n)
			{
				set pow[i] = 2 * pow[i-1]; 
			}
			for (i in 0 .. (n / 2 - 1))
			{
				SWAP(q[i], q[n-1-i]);
			}
			for (i in n-1 .. -1 .. 0)
			{
				for (j in n-1 .. -1 .. i+1)
				{
					(controlled R1)([q[j]], (-2*PI()/pow[j-i+1],q[i]));
				}
				H(q[i]);
			}
		}
	}
	operation PE(x:Int, N:Int, reg2:Qubit[], t:Int, L:Int):(Int[])
	{
		body
		{
			mutable rtn = new Int[t];
			using (reg1 = Qubit[t]) 
			{
				for (i in 0 .. t-1)
				{
					Set(Zero, reg1[i]);
					H(reg1[i]);
				}
				mutable z = x;
				for (i in 0 .. t-1) 
				{
					(Controlled Ux) ([reg1[t - i - 1]], (z, N, reg2));
					set z = z*z%N;
				}
				(Adjoint QFT) (reg1);

				for(i in 0 .. t - 1)
				{
					let result = M(reg1[i]);
					if(result == Zero)
					{
						set rtn[i] = 0;
					}
					if(result == One)
					{
						set rtn[i] = 1;
					}
				}
				ResetAll(reg1);
			}
			return rtn;
		}
	}
	operation QOF(x:Int, N:Int, t:Int, L:Int):(Double)
	{
		body
		{
			mutable phi = 0.0;
			mutable tw = 0.5;
			using (reg2 = Qubit[L])
			{
				for (i in 1 .. L - 1)
				{
					Set(Zero,reg2[i]);
				}
				Set(One, reg2[0]);
				let out = PE(x,N,reg2,t,L);
				for (i in 0 .. t - 1)
				{
					if (out[i] == 1)
					{
						set phi = phi+tw;
					}
					set tw = tw*0.5;
				}
				ResetAll(reg2);
			}
			return phi;
		}
	}
}
# Intro

In Circom all numbers are elements of a finite field with a large prime modulus p (e.g., BN254 $p = 21888242871839275222246405745257275088548364400416034343698204186575808495617)$). So the range of numbers are from $0$ to $p-1$. Also we don't have any floating-point numbers. Negative numbers are represented using the modulus. For example $-1 \mod 7 = 6$. So how does Circom perform this computation?
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}a=10,\;b=12\implies%2010/12=0.8333" />
</div>

# Fermat's Little Theorem

Circom uses Fermat's Little Theorem. Fermat's Little Theorem is a fundamental theorem in number theory that provides a way to compute modular inverses when the modulus is a prime number.
Notation:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}a^p\equiv a\mod p" />
</div>

For example:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}p=7,\;a=2" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}2^7\equiv2\mod7\Rightarrow128\equiv2\mod7,\;(128-18\cdot7=2)" />
</div>

Now in Circom when we want to divide, we are computing this:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{a}{b}\equiv a\cdot b^{-1}\mod p" />
</div>

Where $b^{-1}$ is the modular inverse of $b$, such that

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}b\cdot b^{-1}\equiv 1\mod p" />
</div>

**Important Note**: When you compute $y^{-1} \mod 17$, there is **only one** answer in $\{0, 1, ..., p - 1\}$. For example when you compute $6^{-1} \mod 17 = 3$.
## Proof

Suppose you want to find $y^{-1} \mod p$ for a nonzero $y$ and a prime $p$.
You are looking for $x$ such that: 

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}y\cdot x\equiv 1\mod p" />
</div>

Suppose there are two solutions, $x_1$ and $x_2$, such that: 

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}y\cdot x_1\equiv 1\mod p" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}y\cdot x_2\equiv 1\mod p" />
</div>

Subtract the two equations: 

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}y\cdot x_1-y\cdot x_2\equiv 0\mod p" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}y(x_1 - x_2) \equiv 0 \mod p" />
</div>

Since $p$ is prime and $y \not\equiv 0 \mod p$, $y$ has no zero divisors.
This means the only solution is $x_1 - x_2 \equiv 0 \mod p$, or $x_1 \equiv x_2 \mod p$.



## How $(\frac{x}{y}) \cdot (\frac{y}{x}) = 1$ ?

The important question is, how $(x/y)*(y/x) = 1$ is computed? This is where Fermat's Little Theorem comes into play.
First, let's have a simple example:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x=10,\;y=12,\;p=17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{x}{y} \equiv x \cdot y^{-1} \mod p" />
</div>

For $\frac{10}{12}$ we have:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x=10,\;y=12" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \equiv 10 \cdot y^{-1} \mod 17" />
</div>
such that
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}12 \cdot y^{-1} \equiv 1 \mod 17 \Rightarrow y^{-1} = 10,\;(12 \cdot 10 = 120 \equiv 1 \mod 17)" />
</div>
with that, we have
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \equiv 10 \cdot 10 \mod 17 \Rightarrow 100 \equiv 15 \mod 17" />
</div>
So at the end we have
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \equiv 15 \mod 17" />
</div>

---

Now for $\frac{12}{10}$ we do all of it again:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x=12,\;y=10" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{12}{10} \equiv 12 \cdot y^{-1} \mod 17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}10 \cdot y^{-1} \equiv 1 \mod 17 \Rightarrow y^{-1} = 12,\;(10 \cdot 12 = 120 \equiv 1 \mod 17)" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{12}{10} \equiv 12 \cdot 12 \mod 17 \Rightarrow 144 \equiv 8 \mod 17" />
</div>
So at the end we have
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{12}{10} \equiv 8 \mod 17" />
</div>


So even though $10/12 =15$ and $12/10 = 8$, their product is $1$ in the field. This is due to modular inverses in finite fields with Fermat's Little Theorm.

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \cdot \frac{12}{10} \equiv 15 \cdot 8 = 120 \equiv 1 \mod 17" />
</div>

We can also proof like below

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}(\frac{a}{b}) \cdot (\frac{b}{a}) = (a \cdot b^{-1}) \cdot (b \cdot a^{-1}) = (a \cdot b \cdot b^{-1} \cdot a^{-1}) = (a \cdot a^{-1}) \cdot (b \cdot b^{-1}) = 1 \cdot 1 = 1 (mod p)"/>
</div>

This was all about the checking for zero part of the example.

## How $\frac{x}{y} \equiv x \cdot y^{-1}$ ?

When we are dividing, we get two options, when $x$ is dividable by $y$ and when it is not. In both cases we can use Fermat's Little Theorem to compute the modular inverse of $y$ and then multiply it with $x$ to get the result of the division in the field. \
But before we dive into the examples, keep in mind, $y^{-1}$ is not equal to some floating-point number in this field. So I will use the notation $y^{-1}$ to represent the modular inverse. Hence you may something like $12^{-1} = 10$ in the field, which means $12 \cdot 12^{-1} \equiv 1 \mod p$.

When $x$ is not dividable by $y$, we have:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x=10,\;y=12,\;p=17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \equiv 10 \cdot 12^{-1} \mod 17" />
</div>

Where $12^{-1}$ is the modular inverse of $12$.

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}12 \cdot 12^{-1} \equiv 1 \mod 17 \Rightarrow 12^{-1} = 10,\;(12 \cdot 10 = 120 \equiv 1 \mod 17)" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \equiv 10 \cdot 10 \mod 17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}10 \cdot 10 = 100 \equiv 15 \mod 17" />
</div>

So the result of $10 / 12$ in the field is $15$ (we did this before, mentioned here for clarity).

---

When $x$ is dividable by $y$, we have:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x=12,\;y=6,\;p=17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{12}{6} \equiv 12 \cdot 6^{-1} \mod 17" />
</div>

Where $6^{-1}$ is the modular inverse of $6$.

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}6 \cdot 6^{-1} \equiv 1 \mod 17 \Rightarrow 6^{-1} = 3,\;(6 \cdot 3 = 18 \equiv 1 \mod 17)" />
</div>

So we have
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{12}{6} \equiv 12 \cdot 3 \mod 17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}12 \cdot 3 = 36 \equiv 2 \mod 17" />
</div>

So the result of $12 / 6$ in the field is $2$.

Now in Circom when you use two non-dividable numbers, it will give you a very huge number due to huge large prime modulus. But it doesn't differ.

Below is an example of two non-dividable numbers in Circom, where the modulus is a large prime number (BN254). Numbers are real and you can check them out yourself:

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x=10,\;y=12,\;p=21888242871839275222246405745257275088548364400416034343698204186575808495617" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}\frac{10}{12} \equiv 10 \cdot 12^{-1} \mod 21...17" />
</div>

Where $12^{-1}$ is the modular inverse of $12$

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}12 \cdot 12^{-1} \equiv 1 \mod 21...17 \Rightarrow" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}12^{-1} = 20064222632519335620392538599819168831169334033714698148390020504361157787649" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white},\;(12 \cdot 20064222632519335620392538599819168831169334033714698148390020504361157787649 =" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}240770671590232027444710463197830025974032008404576377780680246052333893451788 \equiv" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}1 \mod 21888242871839275222246405745257275088548364400416034343698204186575808495617)" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}x \cdot 12^{-1} \equiv 10 \cdot 20...49 \mod 17" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}10 \cdot 20...49 = 200642226325193356203925385998191688311693340337146981483900205043611577876490 \equiv" />
</div>
<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}3648040478639879203707734290876212514758060733402672390616367364429301415937 \mod 17" />
</div>

So the result of $10 / 12$ in the field is 

<div align="center">
<img src="https://latex.codecogs.com/svg.image?\color{white}3648040478639879203707734290876212514758060733402672390616367364429301415937" />
</div>

and you will see this huge number in the output of the Circom circuit.



[Fermat's Little Theorem Wikipedia](https://en.wikipedia.org/wiki/Fermat%27s_little_theorem).
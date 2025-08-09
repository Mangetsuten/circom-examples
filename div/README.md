# Intro

In Circom all numbers are elements of a finite field with a large prime modulus p (e.g., BN254 $p = 21888242871839275222246405745257275088548364400416034343698204186575808495617)$). So the range of numbers are from $0$ to $p-1$. Also we don't have any floating-point numbers. Negative numbers are represented using the modulus. For example $-1 \mod 7 = 6$. So how does Circom perform this computation?
$$
a = 10,\ b = 12 => 10 / 12 = 0.8333
$$

# Fermat's Little Theorem

Circom uses Fermat's Little Theorem. Fermat's Little Theorem is a fundamental theorem in number theory that provides a way to compute modular inverses when the modulus is a prime number.
Notation:
$$a^p \equiv a \mod p$$
For example:
$$p = 7,\ a = 2$$
$$2^7 \equiv 2 \mod 7 \Rightarrow 128 \equiv 2 \mod 7,\ (128 - 18 \cdot 7 = 2)$$

Now in Circom when we want to divide, we are computing this:
$$a / b \equiv a \cdot b^{-1} \mod p$$
Where $b^{-1}$ is the modular inverse of $b$, such that
$$b \cdot b^{-1} \equiv 1 \mod p$$


**Important Note**: When you compute $y^{-1} \mod 17$, there is **only one** answer in $\{0, 1, ..., p - 1\}$. For example when you compute $6^{-1} \mod 17 = 3$.
## Proof

Suppose you want to find $y^{-1} \mod p$ for a nonzero $y$ and a prime $p$.
You are looking for $x$ such that: 
$$y \cdot x \equiv 1 \mod p$$

Suppose there are two solutions, $x_1$ and $x_2$, such that: 
$$y \cdot x_1 \equiv 1 \mod p$$
$$y \cdot x_2 \equiv 1 \mod p$$
Subtract the two equations: 
$$y \cdot x_1 - y \cdot x_2 \equiv 0 \mod p \ y(x_1 - x_2) \equiv 0 \mod p$$ 
Since $p$ is prime and $y \not\equiv 0 \mod p$, $y$ has no zero divisors.
This means the only solution is $x_1 - x_2 \equiv 0 \mod p$, or $x_1 \equiv x_2 \mod p$.



## How $(\frac{x}{y}) \cdot (\frac{y}{x}) = 1$ ?

The important question is, how $(x/y)*(y/x) = 1$ is computed? This is where Fermat's Little Theorem comes into play.
First, let's have a simple example:
$$x = 10,\ y = 12,\ p = 17$$
$$\frac{x}{y} \equiv x \cdot y^{-1} \mod p$$
For $\frac{10}{12}$ we have:
$$x = 10,\ y = 12$$
$$\frac{10}{12} \equiv 10 \cdot y^{-1} \mod 17$$
such that
$$12 \cdot y^{-1} \equiv 1 \mod 17 \Rightarrow y^{-1} = 10,\ (12 \cdot 10 = 120 \equiv 1 \mod 17)$$
with that, we have 
$$\frac{10}{12} \equiv 10 \cdot 10 \mod 17 \Rightarrow 100 \equiv 15 \mod 17$$
So at the end we have
$$\frac{10}{12} \equiv 15 \mod 17$$


Now for $\frac{12}{10}$ we do all of it again,
$$x = 12,\ y = 10$$
$$\frac{12}{10} \equiv 12 \cdot y^{-1} \mod 17$$
$$10 \cdot y^{-1} \equiv 1 \mod 17 \Rightarrow y^{-1} = 12,\ (10 \cdot 12 = 120 \equiv 1 \mod 17)$$
$$\frac{12}{10} \equiv 12 \cdot 12 \mod 17 \Rightarrow 144 \equiv 8\mod 17$$
So at the end we have:
$$\frac{12}{10} \equiv 8 \mod 17$$


So even though $10/12 =15$ and $12/10 = 8$, their product is $1$ in the field. This is due to modular inverses in finite fields with Fermat's Little Theorm.
$$\frac{10}{12} \cdot \frac{12}{10} \equiv 15 \cdot 8 = 120 \equiv 1 \mod 17$$
We can also proof like below
$$(\frac{a}{b}) \cdot (\frac{b}{a}) = (a \cdot b^{-1}) \cdot (b \cdot a^{-1}) = (a \cdot b \cdot b^{-1} \cdot a^{-1}) = (a \cdot a^{-1}) \cdot (b \cdot b^{-1}) = 1 \cdot 1 = 1 (mod p)$$
This was all about the checking for zero part of the example.

## How $\frac{x}{y} \equiv x \cdot y^{-1}$ ?

When we are dividing, we get two options, when $x$ is dividable by $y$ and when it is not. In both cases we can use Fermat's Little Theorem to compute the modular inverse of $y$ and then multiply it with $x$ to get the result of the division in the field. \
But before we dive into the examples, keep in mind, $y^{-1}$ is not equal to some floating-point number in this field. So I will use the notation $y^{-1}$ to represent the modular inverse. Hence you may something like $12^{-1} = 10$ in the field, which means $12 \cdot 12^{-1} \equiv 1 \mod p$.

When $x$ is not dividable by $y$, we have:
$$x = 10,\ y = 12,\ p = 17$$
$$\frac{10}{12} \equiv 10 \cdot 12^{-1} \mod 17$$
Where $12^{-1}$ is the modular inverse of $12$
$$12 \cdot 12^{-1} \equiv 1 \mod 17 \Rightarrow 12^{-1} = 10,\ (12 \cdot 10 = 120 \equiv 1 \mod 17)$$
$$x \cdot y^{-1} \equiv 10 \cdot 10 \mod 17$$
$$10 \cdot 10 = 100 \equiv 15 \mod 17$$
So the result of $10 / 12$ in the field is $15$ (we did this before, mentioned here for clarity).

When $x$ is dividable by $y$, we have:
$$\frac{12}{6} \equiv 12 \cdot 6^{-1} \mod 17$$
Where $6^{-1}$ is the modular inverse of $6$
$$6 \cdot 6^{-1} \equiv 1 \mod 17 \Rightarrow 6^{-1} = 3,\ (6 \cdot 3 = 18 \equiv 1 \mod 17)$$
So we have:
$$\frac{12}{6} \equiv 12 \cdot 3 \mod 17$$
$$12 \cdot 3 = 36 \equiv 2 \mod 17$$
So the result of $12 / 6$ in the field is $2$.

Now in Circom when you use two non-dividable numbers, it will give you a very huge number due to huge large prime modulus. But it doesn't differ.

Below is an example of two non-dividable numbers in Circom, where the modulus is a large prime number (BN254). Numbers are real and you can check them out yourself:
$$x = 10,\ y = 12,\ p = 21888242871839275222246405745257275088548364400416034343698204186575808495617$$
$$\frac{10}{12} \equiv 10 \cdot 12^{-1} \mod 21...17$$
Where $12^{-1}$ is the modular inverse of $12$
$$12 \cdot 12^{-1} \equiv 1 \mod 21...17 \Rightarrow 12^{-1} =$$
$$20064222632519335620392538599819168831169334033714698148390020504361157787649$$
$$(12 \cdot 20064222632519335620392538599819168831169334033714698148390020504361157787649 =$$
$$240770671590232027444710463197830025974032008404576377780680246052333893451788 \equiv$$
$$1 \mod 21888242871839275222246405745257275088548364400416034343698204186575808495617)$$
$$x \cdot 12^{-1} \equiv 10 \cdot 20...49 \mod 17$$
$$10 \cdot 20...49 = $$
$$200642226325193356203925385998191688311693340337146981483900205043611577876490 \equiv$$
$$3648040478639879203707734290876212514758060733402672390616367364429301415937 \mod 17$$
So the result of $10 / 12$ in the field is $$3648040478639879203707734290876212514758060733402672390616367364429301415937$$ and you will see this huge number in the output of the Circom circuit. 



[Fermat's Little Theorem Wikipedia](https://en.wikipedia.org/wiki/Fermat%27s_little_theorem).
# this test julia default IO, which is binary IO
# f1 shows how to read char back from binary
# f2-f5 tests the speed of write/read large Float64 Array
# somewhat surprisingly, f3-f5 performs at the same speed

# the ones without preallocation performs at essentially the same speed at FORTRAN
# it is about 0.01s to read 50Mb

const mx=72900
const my=94

# As an exercise, you can count the byte in the testiof1.bin
function f1()
    A=rand(2,2)
    B=rand(3,3)
    c="stupid IO"
    f=open("./testiof1.bin","w")
    write(f,A,B,c)
    close(f)
    println(A,B,c)

    A1=similar(A)
    B1=similar(B)
    c1=" "^length(c)
    f=open("./testiof1.bin","r")
    read!(f,A1)
    read!(f,B1)
 #   c1=join(convert(Array{Char},read(f,length(c1))))  #this works too
    c1=join(Char.(read(f,length(c1))))
    println(A1)
    println(B1)
    println(c1)
end

function f2()
    A=rand(mx,my)
    f=open("./testio.bin","w")
    write(f,A)
    close(f)
    println("writing:",A[1:2,1:2])
end

# if you can read the whole thing
function f3()
    A=Array{Float64}(undef,mx,my)
    f=open("./testio.bin","r")
    read!(f,A)
    close(f)
    println("outputing f3:",A[1:2,1:2])
end

function f3!(A)
    f=open("./testio.bin","r")
    read!(f,A)
    close(f)
    println("outputing f3:",A[1:2,1:2])
end

# if you want to read column by column, somewhat painful as the Ref in unsafe_read
# AND REMEMBER the *8 converting to bytes
# IMPORTANT: Ref(b) actually doesn't point to the INTERIOR of b, but Ref(b,1) does
function f4()
    A=Array{Float64}(undef,mx,my)
    f=open("./testio.bin","r")
    for j=1:my
        b=view(A,:,j)
        unsafe_read(f,Ref(b,1),mx*8)
    end
    println("outputing f4:",A[1:2,1:2])
end

function f4!(A)
    f=open("./testio.bin","r")
    for j=1:my
        b=view(A,:,j)
        unsafe_read(f,Ref(b,1),mx*8)
    end
    println("outputing f4:",A[1:2,1:2])
end


# if not using view, needs to do manual convert cartesian to linear indexing
function f5()
    A=Array{Float64}(undef,mx,my)
    f=open("./testio.bin","r")
    for j=1:my
        unsafe_read(f,Ref(A,(j-1)*mx+1),mx*8)
    end
    println("outputing f5:",A[1:2,1:2])
end

function f5!(A)
    f=open("./testio.bin","r")
    for j=1:my
        unsafe_read(f,Ref(A,(j-1)*mx+1),mx*8)
    end
    println("outputing f5:",A[1:2,1:2])
end

f1()
f2()
@time f2()

f3()
@time f3()

f4()
@time f4()

f5()
@time f5()

println("time the ones with preallocation")
Aout=Array{Float64}(undef,mx,my)
f3!(Aout)
@time f3!(Aout)
Aout=Array{Float64}(undef,mx,my)
f4!(Aout)
@time f4!(Aout)
Aout=Array{Float64}(undef,mx,my)
f5!(Aout)
@time f5!(Aout)


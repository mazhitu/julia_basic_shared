# Looks like unless there's some BLAS function, it's better to just stick to FORTRAN syntax,
# and remember it's a columnwise language
# adding the dot definately helps, but not as fast as FORTRAN syntax

using LinearAlgebra.BLAS

function f2(x,y)
    return x+2y    #this is not good either, because it creates tmp=2y
end

# when called, put a . (i.e. f2v1.)
function f2v1(x,y)
    return x+2y    # not sure why it uses so many allocation, maybe broadcast on 2D is not that efficient??
end
function f2v2!(r,x,y)
    n1::Integer,n2::Integer=size(x)
    for i=1:length(x)   # looks like 2D can be treated as 1D
        r[i]=x[i]+2*y[i]
    end
end
function f2v3!(r,x,y)
    n1::Integer,n2::Integer=size(x)
    i,j=1,1
    for j=1:n2,i=1:n1   # standard FORTRAN loop
        r[i,j]=x[i,j]+2*y[i,j]
    end
end
function f2v4!(r,x,y)
    n1,n2=size(x)
    for i=1:n1,j=1:n2       # if I do row wise, it's the slowest 
        r[i,j]=x[i,j]+2*y[i,j]
    end
end
function f2v5!(r,x,y)
    BLAS.blascopy!(length(x),x,1,r,1)  #some BLAS routine
    BLAS.axpy!(2.0,y,r)
end

function test()
    x=rand(5000,7000)
    y=rand(5000,7000)
    println(x[100:101,100:101],y[100:101,100:101])
    tmp1=similar(x)

    tmp1=f2(x,y)
    println(tmp1[100:101,100:101])
    @time tmp1=f2(x,y)

    tmp1=f2v1.(x,y)
    println(tmp1[100:101,100:101])
    @time tmp1=f2v1.(x,y)

    r=similar(x)
    f2v2!(r,x,y)
    println(r[100:101,100:101])
    @time f2v2!(r,x,y)

    r=similar(x)
    f2v3!(r,x,y)
    println(r[100:101,100:101])
    @time f2v3!(r,x,y)

    r=similar(x)
    f2v4!(r,x,y)
    println(r[100:101,100:101])
    @time f2v4!(r,x,y)

    r=similar(x)
    f2v5!(r,x,y)
    println(r[100:101,100:101])
    @time f2v5!(r,x,y)
end

test()
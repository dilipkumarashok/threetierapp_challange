d = {'a':{'b':{'c':{'d':'e'}}}}
keys = "a/b/c/d"

d1 = {'a':{'b':{'c':'d'}}}
ke = "a/b/c"

object = {"x":{"y":{"z":"a"}}}
key = "x/y/z"

def nested(obj,keys):
    l = keys.split("/")
    m = []
    print(obj)
    for i in l:
        if isinstance(obj[i], dict):
            obj = obj[i]
            for v in obj.values():
                m.append(v)
    print(m.pop())
            
nested(object,key)
nested(d,keys)
nested(d1,ke)
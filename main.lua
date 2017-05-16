require 'torch'
local image = require 'image'

target = {400,100}
new = {0,0}
running = 0
rimcount = 1
lastrim = 0
--this is not call by value
--local function breitensuche(pos,img,depthmap)
--  local rim = {}
--  table.insert(rim,pos)
--  --while(#rim>0 and pos[3]<600) do
--  while(#rim>0 ) do
--    pos = table.remove(rim,1)
--    if (pos[3]%100==0) then
--      depthmap[1][pos[1]][pos[2]] = 0
--    else
--      depthmap[1][pos[1]][pos[2]] = pos[3]
--    end
--    if(pos[1]+1 <= img:size(2) and img[1][pos[1]+1][pos[2]] == 0) then img[1][pos[1]+1][pos[2]] = 100; table.insert(rim,{pos[1]+1,pos[2],pos[3]+1}) end
--    if(pos[2]+1 <= img:size(3) and img[1][pos[1]][pos[2]+1] == 0) then img[1][pos[1]][pos[2]+1] = 100; table.insert(rim,{pos[1],pos[2]+1,pos[3]+1}) 
--    elseif(img[1][pos[1]][1] == 0 and pos[2]+1 > img:size(3)) then img[1][pos[1]][1] = 100; table.insert(rim,{pos[1],1,pos[3]+1}) end
--    if(pos[1]-1 >= 1           and img[1][pos[1]-1][pos[2]] == 0) then img[1][pos[1]-1][pos[2]] = 100; table.insert(rim,{pos[1]-1,pos[2],pos[3]+1}) end
--    if(pos[2]-1 >= 1           and img[1][pos[1]][pos[2]-1] == 0) then img[1][pos[1]][pos[2]-1] = 100; table.insert(rim,{pos[1],pos[2]-1,pos[3]+1}) 
--    elseif(img[1][pos[1]][img:size(3)] == 0 and pos[2]-1 < 1) then img[1][pos[1]][img:size(3)] = 100; table.insert(rim,{pos[1],img:size(3),pos[3]+1}) end
--  end
--end

local function d(pos1,pos2)
  return math.sqrt((pos1[1]-pos2[1])*(pos1[1]-pos2[1])+(pos1[2]-pos2[2])*(pos1[2]-pos2[2]))
end

--local function comptotarget(pos1,pos2)
--  if(pos1[3]+2*d(pos1,target) < pos2[3]+2*d(pos2,target)) then
--    return true
--  else
--    return false
--  end
--end
--parent
--local function astar(pos,img,depthmap)
--  local rim = {}
--  table.insert(rim,pos)
--  while(#rim>0 and d(pos,target) > 1) do
----  while(#rim>0) do
--    table.sort(rim,comptotarget)
--    pos = table.remove(rim,1)
--    depthmap[1][pos[1]][pos[2]] = pos[3]+d(pos,target)
--    if(pos[1]+1 <= img:size(2) and img[1][pos[1]+1][pos[2]] == 0) then img[1][pos[1]+1][pos[2]] = 100; table.insert(rim,{pos[1]+1,pos[2],pos[3]+1,pos}) end
--    if(pos[2]+1 <= img:size(3) and img[1][pos[1]][pos[2]+1] == 0) then img[1][pos[1]][pos[2]+1] = 100; table.insert(rim,{pos[1],pos[2]+1,pos[3]+1,pos}) 
--    elseif(img[1][pos[1]][1] == 0 and pos[2]+1 > img:size(3)) then img[1][pos[1]][1] = 100; table.insert(rim,{pos[1],1,pos[3]+1,{pos[1],pos[2]}}) end
--    if(pos[1]-1 >= 1           and img[1][pos[1]-1][pos[2]] == 0) then img[1][pos[1]-1][pos[2]] = 100; table.insert(rim,{pos[1]-1,pos[2],pos[3]+1,pos}) end
--    if(pos[2]-1 >= 1           and img[1][pos[1]][pos[2]-1] == 0) then img[1][pos[1]][pos[2]-1] = 100; table.insert(rim,{pos[1],pos[2]-1,pos[3]+1,pos}) 
--    elseif(img[1][pos[1]][img:size(3)] == 0 and pos[2]-1 < 1) then img[1][pos[1]][img:size(3)] = 100; table.insert(rim,{pos[1],img:size(3),pos[3]+1,pos}) end
--  end
--  --extract path
--  while(pos[4][1] ~= pos[1] or pos[4][2] ~= pos[2]) do
--    depthmap[1][pos[1]][pos[2]] = 100
--    pos = pos[4]
--  end
--end

local function comp(pos1,pos2)
  if(pos1[3] < pos2[3]) then
    return true
  else
    return false
  end
end

local function comptonew(pos1,pos2)
  if(pos1[3]+d(pos1,new) < pos2[3]+d(pos2,new)) then
    return true
  else
    return false
  end
end

local function getline(pos1,pos2,line)
  --y = a*x+b
  --a = (y2-y1)/(x2-x1)
  --b = y1-a*x1 
  --x = (y-b)/a
  local pos = {0,0}
  local direction = 0
  local line = line or {}
  if(pos2[1]-pos1[1]==0) then
    direction = pos2[2]-pos1[2] > 0 and 1 or -1
    for i = pos1[2], pos2[2], direction do
      pos[1] = pos1[1]
      pos[2] = i
      table.insert(line,{pos[1],pos[2]})
    end
    return line
  end
  if(pos2[2]-pos1[2]==0) then
    direction = pos2[1]-pos1[1] > 0 and 1 or -1
    for i = pos1[1], pos2[1], direction do
      pos[1] = i
      pos[2] = pos1[2]
      table.insert(line,{pos[1],pos[2]})
    end
    return line
  end
  local a = (pos2[2]-pos1[2])/(pos2[1]-pos1[1])
  local b = pos1[2]-a*pos1[1]
  if a<1 and a>-1 then
    direction = pos2[1]-pos1[1] > 0 and 1 or -1
    for i = pos1[1], pos2[1], direction do
      pos[1] = i
      pos[2] = math.ceil(a*i+b)
      table.insert(line,{pos[1],pos[2]})
    end
  else
    direction = pos2[2]-pos1[2] > 0 and 1 or -1
    for i = pos1[2], pos2[2], direction do
      pos[1] = math.ceil((i-b)/a)
      pos[2] = i
      table.insert(line,{pos[1],pos[2]})
    end
  end
  return line
end

--1.expanse next
--2.is path free?
--3.find path free node with shortes way length
--local function ispathfree(pos1,pos2,img)
--  local line = getline(pos1,pos2)
--  for i=1, #line do
--    if img[1][line[i][1]][line[i][2]] ~= 0 then
--      return false
--    end
--  end
--  return true
--end

--ein pixel in bekante zone reinrennen!!!
local function ispathfree2(pos1,parent,pathimg,graph)
  local line = getline(pos1,parent)
  for i=1, #line do
    if i>7 and pathimg[1][line[i][1]][line[i][2]] ~= 100 and graph[line[i][1]][line[i][2]][1] == parent[1] and graph[line[i][1]][line[i][2]][2] == parent[2] then
      return true
    elseif pathimg[1][line[i][1]][line[i][2]] == 200 then
      return false
    end
  end
  return true
end

local function drawline(line,img)
  for i=1, #line do
    img[1][line[i][1]][line[i][2]] = 100 
  end
end

--local function findparent(pos,rim,expansed,pathimg)
--  new = pos
--  table.sort(expansed,comptonew)
--  for i=1, #expansed do
--    --if ispathfree(pos,expansed[i],pathimg) then
--      --pos[4] = expansed[i]
--      --pos[3] = expansed[i][3] + d(pos,expansed[i])
--      if ispathfree(pos,expansed[1],pathimg) then
--        pos[4] = expansed[1]
--        pos[3] = expansed[1][3] + d(pos,expansed[1])
--      print(pos[1],pos[2],pos[3])
--      table.insert(rim,pos)
--      return true
--    end
--    table.remove(expansed,1)
--  end
--    print("fatal")
--    print(pos)
--  return false
--end

--local function ashot(pos,img,depthmap)
--  local pathimg = img:clone()
--  for y=1, pathimg:size(2) do
--    for x=1, pathimg:size(3) do
--      if pathimg[1][y][x] ~= 0 then
--        pathimg[1][y][x] = 200
--      end
--    end
--  end
--  local rim = {}
--  local expansed = {}
--  table.insert(rim,pos)
--  while(#rim>0 and pos[3] < 100) do
--    table.sort(rim,comp)
--    pos = table.remove(rim,1)
--    table.insert(expansed,pos)
--    depthmap[1][pos[1]][pos[2]] = pos[3]
--    if(pos[1]+1 <= img:size(2) and img[1][pos[1]+1][pos[2]] == 0) then img[1][pos[1]+1][pos[2]] = 100; findparent({pos[1]+1,pos[2]},rim,expansed,pathimg) end
--    if(pos[2]+1 <= img:size(3) and img[1][pos[1]][pos[2]+1] == 0) then img[1][pos[1]][pos[2]+1] = 100; findparent({pos[1],pos[2]+1},rim,expansed,pathimg) 
--    elseif(img[1][pos[1]][1] == 0 and pos[2]+1 > img:size(3)) then img[1][pos[1]][1] = 100;            findparent({pos[1],1},rim,expansed,pathimg) end
--    if(pos[1]-1 >= 1           and img[1][pos[1]-1][pos[2]] == 0) then img[1][pos[1]-1][pos[2]] = 100; findparent({pos[1]-1,pos[2]},rim,expansed,pathimg) end
--    if(pos[2]-1 >= 1           and img[1][pos[1]][pos[2]-1] == 0) then img[1][pos[1]][pos[2]-1] = 100; findparent({pos[1],pos[2]-1},rim,expansed,pathimg) 
--    elseif(img[1][pos[1]][img:size(3)] == 0 and pos[2]-1 < 1) then img[1][pos[1]][img:size(3)] = 100;  findparent({pos[1],img:size(3)},rim,expansed,pathimg) end
--  end
--end

local function findparent2(pos,pre,rim,expansed,pathimg,graph,img)
  if ispathfree2(pos,pre[4],pathimg,graph) then
    pos[4] = pre[4] --rep[4] is parent of pre
    graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
    pos[3] = pre[4][3]+d(pos,pre[4])
    --print("("..pos[1]..","..pos[2]..")","d: "..pos[3],"("..pos[4][1]..","..pos[4][2]..")")
    table.insert(rim,pos)
    rimcount = rimcount + 1
    return true
  end
  new = {pos[1],pos[2]}
  --local ext = torch.Tensor(expansed)
  table.sort(expansed,comptonew)
  local count = 0
  --binäre suche oder zumindest ein paar überspringen
  while #expansed>0 do
  --if ispathfree(pos,expansed[i],pathimg) then
    --pos[4] = expansed[i]
    --pos[3] = expansed[i][3] + d(pos,expansed[i])
    --how is this even possible?
    if ispathfree2(pos,expansed[1],pathimg,graph) then
      pos[4] = expansed[1]
      graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
      pos[3] = expansed[1][3] + d(pos,expansed[1])
      print("("..pos[1]..", "..pos[2]..") "," d: "..pos[3],"of "..opt.depth,"("..pos[4][1]..", "..pos[4][2]..") "," search: "..count, "hot: ", #expansed, "rim: ", #rim, "speed: "..math.ceil((((rimcount-lastrim)/#rim)/(os.clock()-running))*1000))
      lastrim = rimcount
      running = os.clock()
      table.insert(rim,pos)
      --img[1][expansed[1][1]][expansed[1][2]] = 150
      return true
    end
    table.remove(expansed,1)
    count = count + 1
  end
  return false
end


local function findparent2NV(pos,pre,rim,expansed,pathimg,graph,img)
  if ispathfree2(pos,pre[4],pathimg,graph) then
    pos[4] = pre[4] --rep[4] is parent of pre
    graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
    pos[3] = pre[4][3]+d(pos,pre[4])
    --print("("..pos[1]..","..pos[2]..")","d: "..pos[3],"("..pos[4][1]..","..pos[4][2]..")")
    table.insert(rim,pos)
    return true
  end
  new = {pos[1],pos[2]}
  --local ext = torch.Tensor(expansed)
  table.sort(expansed,comptonew)
  local count = 0
  --binäre suche oder zumindest ein paar überspringen
  while #expansed>0 do
  --if ispathfree(pos,expansed[i],pathimg) then
    --pos[4] = expansed[i]
    --pos[3] = expansed[i][3] + d(pos,expansed[i])
    --how is this even possible?
    if ispathfree2(pos,expansed[1],pathimg,graph) then
      pos[4] = expansed[1]
      graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
      pos[3] = expansed[1][3] + d(pos,expansed[1])
      --print("("..pos[1]..", "..pos[2]..") "," d: "..pos[3],"("..pos[4][1]..", "..pos[4][2]..") "," search: "..count, "hot: ", #expansed, "rim: ", #rim, "total: " , (#expansed*#rim*pos[3]/1000000).." mio")
      table.insert(rim,pos)
      --img[1][expansed[1][1]][expansed[1][2]] = 150
      return true
    end
    table.remove(expansed,1)
    count = count + 1
  end
  return false
end

local function astar2(max,pos,img,depthmap,graph,color)
  local pathimg = img:clone()
  for y=1, pathimg:size(2) do
    for x=1, pathimg:size(3) do
      if pathimg[1][y][x] ~= 0 then
        pathimg[1][y][x] = 200
      end
    end
  end
  local rim = {}
  local expansed = {}
  table.insert(expansed,{pos[1],pos[2],pos[3]}) 
  table.insert(rim,pos)
  while(#rim>0 and pos[3] < max) do
--  while(#rim>0) do
    table.sort(rim,comp)
    pos = table.remove(rim,1)
    table.insert(expansed,{pos[1],pos[2],pos[3]}) 
    
    if (math.ceil(pos[3])%100==0) then
      depthmap[1][pos[1]][pos[2]] = 0
    else
      depthmap[1][pos[1]][pos[2]] = pos[3]
      --color[1][pos[1]][pos[2]] = pos[4][1]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      --color[2][pos[1]][pos[2]] = pos[4][2]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      --color[3][pos[1]][pos[2]] = math.abs(pos[4][2]%150-pos[4][1]%150)+(pos[4][3]/max*100)-(pos[3]/max*100)
    end
    
    --depthmap[1][pos[1]][pos[2]] = pos[3]
    if(pos[1]+1 < pathimg:size(2) and pathimg[1][pos[1]+1][pos[2]] == 0) then  findparent2({pos[1]+1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]+1][pos[2]] = 100        end
    if(pos[2]+1 < pathimg:size(3) and pathimg[1][pos[1]][pos[2]+1] == 0) then  findparent2({pos[1],pos[2]+1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]+1] = 100        
    elseif(pathimg[1][pos[1]][1] == 0 and pos[2]+1 > pathimg:size(3))     then  findparent2({pos[1],1},pos,rim,expansed,pathimg,graph,img)              ; pathimg[1][pos[1]][1] = 100               end
    if(pos[1]-1 > 1           and pathimg[1][pos[1]-1][pos[2]] == 0)     then  findparent2({pos[1]-1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]-1][pos[2]] = 100        end
    if(pos[2]-1 > 1           and pathimg[1][pos[1]][pos[2]-1] == 0)     then  findparent2({pos[1],pos[2]-1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]-1] = 100        
    elseif(pathimg[1][pos[1]][pathimg:size(3)] == 0 and pos[2]-1 < 1)     then  findparent2({pos[1],pathimg:size(3)},pos,rim,expansed,pathimg,graph,img); pathimg[1][pos[1]][pathimg:size(3)] = 100 end
    --umbruch richtig versuchen!
  end
  return pathimg
end



local function astar2NV(max,pos,img,depthmap,graph,color)
  local pathimg = img:clone()
  for y=1, pathimg:size(2) do
    for x=1, pathimg:size(3) do
      if pathimg[1][y][x] ~= 0 then
        pathimg[1][y][x] = 200
      end
    end
  end
  local rim = {}
  local expansed = {}
  table.insert(expansed,{pos[1],pos[2],pos[3]}) 
  table.insert(rim,pos)
  while(#rim>0 and pos[3] < max) do
--  while(#rim>0) do
    table.sort(rim,comp)
    pos = table.remove(rim,1)
    table.insert(expansed,{pos[1],pos[2],pos[3]})
    
    if (math.ceil(pos[3])%100==0) then
      depthmap[1][pos[1]][pos[2]] = 0
    else
      depthmap[1][pos[1]][pos[2]] = pos[3]
      --color[1][pos[1]][pos[2]] = pos[4][1]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      --color[2][pos[1]][pos[2]] = pos[4][2]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      --color[3][pos[1]][pos[2]] = math.abs(pos[4][2]%150-pos[4][1]%150)+(pos[4][3]/max*100)-(pos[3]/max*100)
    end
    
    --depthmap[1][pos[1]][pos[2]] = pos[3]
    if(pos[1]+1 < pathimg:size(2) and pathimg[1][pos[1]+1][pos[2]] == 0) then  findparent2NV({pos[1]+1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]+1][pos[2]] = 100        end
    if(pos[2]+1 < pathimg:size(3) and pathimg[1][pos[1]][pos[2]+1] == 0) then  findparent2NV({pos[1],pos[2]+1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]+1] = 100        end
    if(pos[1]-1 > 1           and pathimg[1][pos[1]-1][pos[2]] == 0)     then  findparent2NV({pos[1]-1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]-1][pos[2]] = 100        end
    if(pos[2]-1 > 1           and pathimg[1][pos[1]][pos[2]-1] == 0)     then  findparent2NV({pos[1],pos[2]-1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]-1] = 100        end
    --polare verzerrung vorher berechnen und startpunkt in bildmitte setzen!
  end
  return pathimg
end

local function findparent(pos,pre,rim,expansed,pathimg,graph,img)
  local parent = pre[4]
  local child = {}
  table.insert(child,1,parent)
  while parent[4][1] ~= parent[1] or parent[4][2] ~= parent[2] do
    table.insert(child,1,parent[4])
    parent = parent[4]
  end
  for i = 1, #child do
    if ispathfree2(pos,child[i],pathimg,graph) then
      pos[4] = child[i] --rep[4] is parent of pre
      graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
      pos[3] = child[i][3]+d(pos,child[i])
      --print("("..pos[1]..","..pos[2]..")","d: "..pos[3],"("..pos[4][1]..","..pos[4][2]..")")
      table.insert(rim,pos)
      rimcount = rimcount + 1
      return true
    end
  end
  new = {pos[1],pos[2]}
  --local ext = torch.Tensor(expansed)
  table.sort(expansed,comptonew)
  local count = 0
  local toelapse = 0
  --binäre suche oder zumindest ein paar überspringen
  while #expansed>0 do
  --if ispathfree(pos,expansed[i],pathimg) then
    --pos[4] = expansed[i]
    --pos[3] = expansed[i][3] + d(pos,expansed[i])
    --how is this even possible?
    if ispathfree2(pos,expansed[1],pathimg,graph) then
      pos[4] = expansed[1]
      graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
      pos[3] = expansed[1][3] + d(pos,expansed[1])
      toelapse = (0.5)*(#rim/opt.depth)*((opt.depth-pos[3])*(opt.depth-pos[3]))+(#rim*(opt.depth-pos[3]))
      print("("..pos[1]..", "..pos[2]..") ", "("..pos[4][1]..", "..pos[4][2]..") ", " d: "..pos[3], " search: "..count, "hot: ", #expansed, "rim: ", #rim, "pre hops: "..#child, "past time: "..os.clock, "remaining time: ~"..(toelapse*((os.clock()-running)/(rimcount-lastrim))).."s")
      lastrim = rimcount
      running = os.clock()
      table.insert(rim,pos)
      img[1][expansed[1][1]][expansed[1][2]] = 150
      return true
    end
    table.remove(expansed,1)
    count = count + 1
  end
  return false
end

local function findparentNV(pos,pre,rim,expansed,pathimg,graph,img)
  local parent = pre[4]
  local child = {}
  table.insert(child,1,parent)
  while parent[4][1] ~= parent[1] or parent[4][2] ~= parent[2] do
    table.insert(child,1,parent[4])
    parent = parent[4]
  end
  for i = 1, #child do
    if ispathfree2(pos,child[i],pathimg,graph) then
      pos[4] = child[i] --rep[4] is parent of pre
      graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
      pos[3] = child[i][3]+d(pos,child[i])
      --print("("..pos[1]..","..pos[2]..")","d: "..pos[3],"("..pos[4][1]..","..pos[4][2]..")")
      table.insert(rim,pos)
      rimcount = rimcount + 1
      return true
    end
  end
  new = {pos[1],pos[2]}
  --local ext = torch.Tensor(expansed)
  table.sort(expansed,comptonew)
  local count = 0
  --binäre suche oder zumindest ein paar überspringen
  while #expansed>0 do
  --if ispathfree(pos,expansed[i],pathimg) then
    --pos[4] = expansed[i]
    --pos[3] = expansed[i][3] + d(pos,expansed[i])
    --how is this even possible?
    if ispathfree2(pos,expansed[1],pathimg,graph) then
      pos[4] = expansed[1]
      graph[pos[1]][pos[2]] = {pos[4][1],pos[4][2]}
      pos[3] = expansed[1][3] + d(pos,expansed[1])
      --print("("..pos[1]..", "..pos[2]..") "," d: "..pos[3],"of "..opt.depth,"("..pos[4][1]..", "..pos[4][2]..") "," search: "..count, "hot: ", #expansed, "rim: ", #rim, "pre hops: "..#child, "speed: "..math.ceil((((rimcount-lastrim)/#rim)/(os.clock()-running))*1000))
      --lastrim = rimcount
      --running = os.clock()
      table.insert(rim,pos)
      --img[1][expansed[1][1]][expansed[1][2]] = 150
      return true
    end
    table.remove(expansed,1)
    count = count + 1
  end
  return false
end

local function astar(max,pos,img,depthmap,graph,color)
  local pathimg = img:clone()
  for y=1, pathimg:size(2) do
    for x=1, pathimg:size(3) do
      if pathimg[1][y][x] ~= 0 then
        pathimg[1][y][x] = 200
      end
    end
  end
  local rim = {}
  local expansed = {}
  table.insert(expansed,pos) 
  table.insert(rim,pos)
  while(#rim>0 and pos[3] < max) do
--  while(#rim>0) do
    table.sort(rim,comp)
    pos = table.remove(rim,1)
    table.insert(expansed,pos)
    
    if (math.ceil(pos[3])%100==0) then
      depthmap[1][pos[1]][pos[2]] = 0
    else
      depthmap[1][pos[1]][pos[2]] = pos[3]
      color[1][pos[1]][pos[2]] = pos[4][1]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      color[2][pos[1]][pos[2]] = pos[4][2]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      color[3][pos[1]][pos[2]] = math.abs(pos[4][2]%150-pos[4][1]%150)+(pos[4][3]/max*100)-(pos[3]/max*100)
    end
    
    --depthmap[1][pos[1]][pos[2]] = pos[3]
    if(pos[1]+1 < pathimg:size(2) and pathimg[1][pos[1]+1][pos[2]] == 0) then  findparent({pos[1]+1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]+1][pos[2]] = 100        end
    if(pos[2]+1 < pathimg:size(3) and pathimg[1][pos[1]][pos[2]+1] == 0) then  findparent({pos[1],pos[2]+1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]+1] = 100        end
    if(pos[1]-1 > 1           and pathimg[1][pos[1]-1][pos[2]] == 0)     then  findparent({pos[1]-1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]-1][pos[2]] = 100        end
    if(pos[2]-1 > 1           and pathimg[1][pos[1]][pos[2]-1] == 0)     then  findparent({pos[1],pos[2]-1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]-1] = 100        end
  end
  return pathimg
end


--final preferierter modus
local function astarNV(max,pos,img,depthmap,graph,color)
  local pathimg = img:clone()
  for y=1, pathimg:size(2) do
    for x=1, pathimg:size(3) do
      if pathimg[1][y][x] ~= 0 then
        pathimg[1][y][x] = 200
      end
    end
  end
  local rim = {}
  local expansed = {}
  table.insert(expansed,pos) 
  table.insert(rim,pos)
  while(#rim>0 and pos[3] < max) do
--  while(#rim>0) do
    table.sort(rim,comp)
    pos = table.remove(rim,1)
    table.insert(expansed,pos) 
    
    if (math.ceil(pos[3])%100==0) then
      depthmap[1][pos[1]][pos[2]] = 0
    else
      depthmap[1][pos[1]][pos[2]] = pos[3]
      --color[1][pos[1]][pos[2]] = pos[4][1]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      --color[2][pos[1]][pos[2]] = pos[4][2]%150+(150-(pos[4][1]%150+pos[4][2]%150))/2+(pos[4][3]/max*100)-(pos[3]/max*100)
      --color[3][pos[1]][pos[2]] = math.abs(pos[4][2]%150-pos[4][1]%150)+(pos[4][3]/max*100)-(pos[3]/max*100)
    end
    
    --depthmap[1][pos[1]][pos[2]] = pos[3]
    if(pos[1]+1 < pathimg:size(2) and pathimg[1][pos[1]+1][pos[2]] == 0) then  findparentNV({pos[1]+1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]+1][pos[2]] = 100        end
    if(pos[2]+1 < pathimg:size(3) and pathimg[1][pos[1]][pos[2]+1] == 0) then  findparentNV({pos[1],pos[2]+1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]+1] = 100        end
    if(pos[1]-1 > 1           and pathimg[1][pos[1]-1][pos[2]] == 0)     then  findparentNV({pos[1]-1,pos[2]},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]-1][pos[2]] = 100        end
    if(pos[2]-1 > 1           and pathimg[1][pos[1]][pos[2]-1] == 0)     then  findparentNV({pos[1],pos[2]-1},pos,rim,expansed,pathimg,graph,img)       ; pathimg[1][pos[1]][pos[2]-1] = 100        end
    
  end
  return pathimg
end




local function main()
  local cmd = torch.CmdLine()
  cmd:text()
  cmd:text('ashot calculates shortest distances like astar...')
  cmd:text('Example:')
  cmd:text('$> luajit -lenv main.lua --y 400 --x 600 --depth 300 --v 1')
  cmd:text('Options:')
  cmd:option('--x', 400, 'start position x value')
  cmd:option('--y', 600, 'start position y value')
  cmd:option('--depth', 300, 'depth of search')
  cmd:option('--v', 1, '0 = do not show debug messages and no aShotmap')
  cmd:option('--a', 1, '0 = fast up some things (increase some small errors)')


  cmd:text()
  opt = cmd:parse(arg or {})
  if not opt.silent then
    print(opt)
  end

  opt.x =tonumber(opt.x)
  opt.y = tonumber(opt.y)
  opt.depth = tonumber(opt.depth)
  opt.v = tonumber(opt.v)
  opt.a = tonumber(opt.a)


  


  local img = image.load("allies342.png",1,'byte')
  local color = torch.Tensor(3,img:size(2),img:size(3)):zero()
  local depthmap = torch.Tensor(1,img:size(2),img:size(3)):zero()
  local graph = {}
  for y=1, img:size(2) do
    local row = {}
    for x=1, img:size(3) do
      table.insert(row,{0,0})
    end
    table.insert(graph,row)
  end
  print("img size: ",img:size(2),img:size(3))
  local pos = {opt.y,opt.x,0}
  pos[4] = pos
  img[1][pos[1]][pos[2]] = 0
  local tmp = img:clone()
  local pathimg = img:clone()
  if opt.a==0 then
    print("accurate == false")
    if opt.v==0 then
      print("verbose == false")
      print(os.date("%X", os.time()))
      pathimg = astar2NV(opt.depth,pos,tmp,depthmap,graph,color)
    else
      print(os.date("%X", os.time()))
      pathimg = astar2(opt.depth,pos,tmp,depthmap,graph,color)
    end
  else
     if opt.v==0 then
      print("verbose == false")
      print(os.date("%X", os.time()))
      pathimg = astarNV(opt.depth,pos,tmp,depthmap,graph,color)
    else
      print(os.date("%X", os.time()))
      pathimg = astar(opt.depth,pos,tmp,depthmap,graph,color)
    end
  end
  --image.display(tmp)
  --image.display(color)
  --image.display(depthmap)
  --print("convert pathimg...")
  local max = 1
  --for y=1, pathimg:size(2) do
  --  for x=1, pathimg:size(3) do
  --    max = max < pathimg[1][y][x] and pathimg[1][y][x] or max
  --  end
  --end
  --for y=1, pathimg:size(2) do
  --  for x=1, pathimg:size(3) do
  --    pathimg[1][y][x] = pathimg[1][y][x]/max
  --  end
  --end
  --max = 1
  --print("convert img...")
  --for y=1, tmp:size(2) do
  --  for x=1, tmp:size(3) do
  --    max = max < tmp[1][y][x] and tmp[1][y][x] or max
  --  end
  --end
  --for y=1, tmp:size(2) do
  --  for x=1, tmp:size(3) do
  --    tmp[1][y][x] = tmp[1][y][x]/max
  --  end
  --end
  --max = 1
  print("done")
  print(os.date("%X", os.time()))
  print(os.clock())
  
  print("convert ashot...")
  local max1 = 1
  local max2 = 1
  local max3 = 1
  for y=1, color:size(2) do
    for x=1, color:size(3) do
      max1 = max1 < color[1][y][x] and color[1][y][x] or max1
      max2 = max2 < color[2][y][x] and color[2][y][x] or max2
      max3 = max3 < color[3][y][x] and color[3][y][x] or max3
    end
  end
  for y=1, color:size(2) do
    for x=1, color:size(3) do
      color[1][y][x] = color[1][y][x]/max1
      color[2][y][x] = color[2][y][x]/max2
      color[3][y][x] = color[3][y][x]/max3
    end
  end
  print("convert depthmap...")
  for y=1, depthmap:size(2) do
    for x=1, depthmap:size(3) do
      max = max < depthmap[1][y][x] and depthmap[1][y][x] or max
    end
  end
  for y=1, depthmap:size(2) do
    for x=1, depthmap:size(3) do
      depthmap[1][y][x] = depthmap[1][y][x]/max
    end
  end
  max = 1
  print("fast expansed nodes: ", rimcount)
  image.save("pathimg.png", pathimg)
  image.save("img.png", tmp)
  image.save("ashot.png", color)
  image.save("depthmap.png", depthmap)
end










--local function main2()
--  local img = image.load("allies342.png",1,'byte')
--  local depthmap = torch.Tensor(1,img:size(2),img:size(3)):zero()
--  local pos = {190,600,0}
--  pos[4] = pos
--  --print(img[1][0][0])
--  image.display(img)
--  --astar(pos,img,depthmap)
--  --image.display(img)
--  --image.display(depthmap)
--  --local pos1 = {200,293}
--  --local pos2 = {530,500}
--  --local line = {}
--  --getline(pos1,pos2,line)
--  local tmp = img:clone()
--  --drawline(line,tmp)
--  --image.display(tmp)
--  --print(line)
--  --print(ispathfree(pos1,pos2,img))
--  ashot(pos,tmp,depthmap)
--  image.display(tmp)
--  image.display(depthmap)
--end


























--local function expanse(pos,img,depth,depthmap)
--  if(depth<20+math.sqrt((startpixel[1]-pos[1])*(startpixel[1]-pos[1])+(startpixel[2]-pos[2])*(startpixel[2]-pos[2]) ))then
--    depth = depth + 1
--    depthmap[1][pos[1]][pos[2]] = depth
--    if(pos[1]+1 <= img:size(2) and img[1][pos[1]+1][pos[2]] == 0) then img[1][pos[1]+1][pos[2]] = 100; img,depth = expanse({pos[1]+1,pos[2]},img,depth,depthmap) end
--    if(pos[2]+1 <= img:size(3) and img[1][pos[1]][pos[2]+1] == 0) then img[1][pos[1]][pos[2]+1] = 100; img,depth = expanse({pos[1],pos[2]+1},img,depth,depthmap) end
--    if(pos[1]-1 > 1 and img[1][pos[1]-1][pos[2]] == 0) then img[1][pos[1]-1][pos[2]] = 100; img,depth = expanse({pos[1]-1,pos[2]},img,depth,depthmap) end
--    if(pos[2]-1 > 1 and img[1][pos[1]][pos[2]-1] == 0) then img[1][pos[1]][pos[2]-1] = 100; img,depth = expanse({pos[1],pos[2]-1},img,depth,depthmap) end
--    depth = depth - 1
--  end
--  return img,depth
--end
--
--local function test()
--  local img = image.load("map.png",1,'byte')
--  image.display(img)
--  local tmp = img:clone()
--  startpixel = {10,130}
--  local pos = startpixel
--  --print(img[1][pos[1]][pos[2]])
--  local depthmap = torch.Tensor(1,img:size(2),img:size(3)):zero()
--  local depth = 0
--  tmp = expanse(pos,tmp,depth,depthmap)
--  image.display(tmp)
--  image.display(depthmap)
--end

main()
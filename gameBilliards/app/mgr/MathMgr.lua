mathMgr = mathMgr or {}

function mathMgr:init()
    
end

--ͨ�÷���������С��λ������
function GetPreciseDecimal(num)
    return num - num % 0.00001
end

function mathMgr:getAngular(args)
    
end

--���ݴ������жϺ����γɵĽǶ�
--@touchPos ������
--@ballX ����X
--@ballY ����Y
--@return ���ص�����γɵĽǶ�
function mathMgr:getAngularByTouchPosAndBallPos(touchPos,ballX,ballY)
    local rotateX = ballX-touchPos.x
    local rotateY = ballY-touchPos.y
    local rotate = math.atan(rotateY/rotateX)*180/math.pi
    if rotateX >= 0 and rotateY >= 0 then
        rotate = 180 - rotate
    elseif rotateX <= 0 and rotateY <= 0 then
        rotate = 360-rotate
    elseif rotateX <= 0 and rotateY >= 0 then
        rotate = math.abs(rotate)
    elseif rotateX >= 0 and rotateY <= 0 then
        rotate = 180+math.abs(rotate)
    end
    return rotate
end

--��������ʱ���ȡ��˵�λ�Ʒ����λ��
--@cueRotate ���ӵ�ת����
--@percent �������ٷֱ�
function mathMgr:getCuePosByRotate(cueRotate,percent)
    cueRotate = mathMgr:changeAngleTo0to360(cueRotate)
--    if cueRotate < 0 then
--        cueRotate = cueRotate + 360 * -math.modf(cueRotate/360)+360
--    elseif cueRotate > 360 then
--        cueRotate = cueRotate - 360 * math.modf(cueRotate/360)
--    end
    local posX,posY
    if cueRotate >= 0 and cueRotate < 90 then
        cueRotate = cueRotate/180*math.pi
        posX = - math.cos(cueRotate)*percent
        posY = math.sin(cueRotate)*percent
    elseif cueRotate >= 90 and cueRotate < 180 then
        cueRotate = cueRotate/180*math.pi
        posX = math.sin(cueRotate-math.pi/2)*percent
        posY = math.cos(cueRotate-math.pi/2)*percent
    elseif cueRotate >= 180 and cueRotate < 270 then
        cueRotate = cueRotate/180*math.pi
        posX = math.cos(cueRotate-math.pi)*percent
        posY = - math.sin(cueRotate-math.pi)*percent
    elseif cueRotate >= 270 and cueRotate < 360 then
        cueRotate = cueRotate/180*math.pi
        posX = -math.sin(cueRotate-math.pi*1.5)*percent
        posY = -math.cos(cueRotate-math.pi*1.5)*percent
    end
    return posX,posY
end

--�ж�԰�Ƿ�;�����ײ
function mathMgr.circleIntersectRect(_circle_pt, _rect,_width,_height,_radius)
    local cx = nil
    local cy = nil
    local circle_pt = {}
    local rect = {}
    circle_pt.x = _circle_pt.x
    circle_pt.y = _circle_pt.y
    rect.width = _width
    rect.height = _height
    rect.x = _rect.x
    rect.y = _rect.y

    --print("====",rect.x,rect.y,circle_pt.x,circle_pt.y)
    -- Find the point on the collision box closest to the center of the circle  
    if circle_pt.x < rect.x then
        cx = rect.x  
    elseif circle_pt.x > rect.x + rect.width then  
        cx = rect.x + rect.width
    else
        cx = circle_pt.x
    end
  
    if circle_pt.y < rect.y then
        cy = rect.y
    elseif circle_pt.y > rect.y + rect.height then
        cy = rect.y + rect.height
    else
        cy = circle_pt.y
    end
    print("=====",cc.pGetDistance(circle_pt, cc.p(cx, cy)),_radius)
    if cc.pGetDistance(circle_pt, cc.p(cx, cy)) < _radius then
        return true
    end
    return false
end

function mathMgr.twoDistance(X1,Y1,X2,Y2)
    return math.pow((math.pow((X1 - X2), 2) + math.pow((Y1 - Y2), 2)), 0.5)
end

function mathMgr.rot(x1,y1,x2,y2)
    local value = (y1-y2)/(x1-x2)
    return math.atan(value)*180/math.pi
end

--��������֮���ƽ��
function mathMgr.getDistancePow2(x1, y1, x2, y2)
    return math.pow((x1 - x2), 2) + math.pow((y1 - y2), 2)
end

function mathMgr.computeCollision(w, h, r, newrx, newry)
      local dx = math.min(newrx, w * 0.5)
      local dx1 = math.max(dx, -w * 0.5)
      local dy = math.min(newry, h * 0.5)
      local dy1 = math.max(dy, -h * 0.5)
      return (dx1 - newrx) * (dx1 - newrx) + (dy1 - newry) * (dy1 - newry) <= r * r
end

function mathMgr.getNewRx_Ry(x1,y1,x2,y2,rotation)
    local json = {}
    local distance = mathMgr.twoDistance(x1,y1,x2,y2)
    --�������½Ƕȣ���X��ĽǶȣ���ͬ��ѧX Y��
    local newrot = mathMgr.rot(x1,y1,x2,y2) - rotation
    local newRx = math.cos(newrot/180*math.pi) * distance
    local newRy = math.sin(newrot/180*math.pi) * distance
    json.newRx = newRx
    json.newRy = newRy
    return json
end

--�㵽ֱ����̾���
function mathMgr.getShortestDistanceBetweenPointAndLine(rotate,ballPos,whitePos,radius)
    local A,B,C = mathMgr.getLineEquation(rotate / 180 * math.pi, whitePos)
    local _verticalLine = math.abs(A*ballPos.x+B*ballPos.y+C)/math.sqrt(A*A+B*B)
    return math.sqrt(4*radius*radius-_verticalLine*_verticalLine)
end

--��ȡ���ߵķ���ʽ return y=kx+b
function mathMgr.getLineEquation(rotate, whitePos)
    local A = -math.tan(rotate)
    local B = 1
    local C = math.tan(rotate)*whitePos.x - whitePos.y
    return A,B,C
end

--���������ȡ��һ��Բ�ϵĽ���
--@whiteCollisionPoint �����node����
--@ballCollisionPoint �����node����
--@radius ��İ뾶
function mathMgr.getPointOnCircle(_self,_whiteCollisionPoint,_ballCollisionPoint,radius)
    print("====",_ballCollisionPoint.x,_whiteCollisionPoint.x,_ballCollisionPoint.y,_whiteCollisionPoint.y)
    if _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        return _self.node:convertToNodeSpace(cc.p((1.5*_ballCollisionPoint.x-0.5*_whiteCollisionPoint.x),
        (_whiteCollisionPoint.y+1.5*(math.sqrt(4*_radius*_radius-math.pow(_ballCollisionPoint.x-_whiteCollisionPoint.x,2))))))
    elseif _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        
    elseif _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        
    elseif _ballCollisionPoint.x >= _whiteCollisionPoint.x and _ballCollisionPoint.y >= _whiteCollisionPoint.y then
        
    end
end

--�ж�ֱ�ߺͱ߿����ײ��
--@rotate ��ת�Ƕȣ���ѧ�Ƕ�
--@whitePos �����node���λ��
--@radius ����뾶
--@return λ�� bool:�Ƿ����볤����ײ
function mathMgr:getLineLengthBetweenPointAndLine(rotate, whitePos, radius)
    while rotate < 0 do
        rotate = 360 + rotate
    end
    while rotate > 360 do
        rotate = rotate - 360
    end
    whitePos.x = whitePos.x - 58
    whitePos.y = whitePos.y - 59
    local borderWidth, borderHeight = 854, 431
    if rotate <= 90 then
        rotate = rotate / 180 * math.pi
        local _traH =(borderWidth - whitePos.x) * math.tan(rotate)
        if _traH <=(borderHeight - whitePos.y) then
            return _traH / math.sin(rotate)-radius/math.cos(rotate)
        else
            return(borderHeight - whitePos.y) / math.sin(rotate)-radius/math.sin(rotate)
        end
    elseif rotate <= 180 then
        rotate =(180 - rotate) / 180 * math.pi
        local _traH =(whitePos.x) * math.tan(rotate)
        if _traH <=(borderHeight - whitePos.y) then
            return _traH / math.sin(rotate)-radius/math.cos(rotate)
        else
            return(borderHeight - whitePos.y) / math.sin(rotate)-radius/math.sin(rotate)
        end
    elseif rotate <= 270 then
        rotate =(rotate - 180) / 180 * math.pi
        local _traH =(whitePos.x) * math.tan(rotate)
        if _traH <= whitePos.y then
            return _traH / math.sin(rotate)-radius/math.cos(rotate)
        else
            return(whitePos.y) / math.sin(rotate)-radius/math.sin(rotate)
        end
    elseif rotate <= 360 then
        rotate =(360 - rotate) / 180 * math.pi
        local _traH = (borderWidth - whitePos.x)*math.tan(rotate)
        if _traH <= whitePos.y then
            return(borderWidth - whitePos.x) / math.cos(rotate)-radius/math.cos(rotate)
        else
            return(whitePos.y) / math.sin(rotate)-radius/math.sin(rotate)
        end
    end
    return 0
end

--�ѽǶ�ת��Ϊ0-360��֮��ʹ��(��Ҫ)
--@ angle ��ʼ�Ƕ�
function mathMgr:changeAngleTo0to360(angle)
    if angle < 0 then
        angle = angle + 360 * - math.modf(angle / 360) + 360
    elseif angle > 360 then
        angle = angle - 360 * math.modf(angle / 360)
    end
    return angle
end

--�жϰ���λ���Ƿ�Ϸ�
--@ rootNode ��Ϸͼ��self
--@ pos ����λ�ã�desk�����λ��
--@ ball ������
function mathMgr:checkBallLocationIsLegal(rootNode, pos, whiteBall)
    local desk = rootNode.desk
    local radius = whiteBall:getContentSize().width / 2
    local deskWidth = rootNode.desk:getContentSize().width
    local deskHeight = rootNode.desk:getContentSize().height
    local distance = whiteBall:getContentSize().width
    local ballPosX, ballPosY
    if pos.x >(60 + radius) and pos.x <(913 - radius) and pos.y >(60 + radius) and pos.y <(489 - radius) then
        for i = 1, 15 do
            local ball = desk:getChildByTag(i)
            if ball then
                ballPosX, ballPosY = ball:getPosition()
                if mathMgr.getDistancePow2(ballPosX, ballPosY, pos.x, pos.y) <= distance * distance then
                    return false
                end
            end
        end
        return true
    end
    return false
end

return mathMgr
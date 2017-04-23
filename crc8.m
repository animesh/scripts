function code=crc( msg )
% function for row by row encoding of msg

% generator polynomial
generator = [1 0 0 0 0 0 1 1 1]; % 8bit CRC

c = [1 0 0 0 0 0 0 0 0]; % x^k

for k=1:size(msg,1)
  multip=conv(c,msg(k,:));
  [divid, remainder]=deconv(multip,generator);
  remainder=mod(remainder,2);
  code(k,:)=xor(multip,remainder);
end

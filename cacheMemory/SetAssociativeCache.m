% N-way Set Associative Cache
clc        % clear command window
clear all  % clear all variables

% Initialize cache setup
sequence = [16 20 24 28 32 36 60 64 72 76 92 96 100 104 108 112 ...
            120 124 128 144 148];
wordBits = 32;
valid = 1;
N = 2;
rows = 2;
index = log2(rows);
blockSizeWords = 4;              
blockSizeBytes = (blockSizeWords*wordBits)/8;
blockSizeBits = blockSizeWords*wordBits;
offset = log2(blockSizeBytes);
LRU = ceil(log2(blockSizeWords));
tag = 16-offset-index;
usedBits = rows*N*(valid+tag+blockSizeBits+LRU);
totalStorage = 900;
unusedBits = totalStorage-usedBits;
hitTime = 1;
missTime = 20+blockSizeBytes;

% Print out cache setup
fprintf('%d-way set associative cache with %d rows and %d bytes per row:\n',...
        N,rows, blockSizeBytes);
fprintf('Offset address bits: %d\n', offset);
fprintf('Bits in the index bit: %d\n', index);
fprintf('Bits in the valid bit: %d\n', valid);
fprintf('Bits in the data block: %d\n', blockSizeBits);
fprintf('Bits in the tag: %d\n', tag);
fprintf('Bits in the LRU: %d\n', LRU);
fprintf('Total bits used: %d, bits remaining: %d\n', usedBits,unusedBits);
fprintf('Hit time: %d\n', hitTime);
fprintf('Miss time: %d\n\n', missTime);

% Initialize cache
sequenceLength = length(sequence);
cacheRowValidBit = zeros(rows*N,1);
cacheTag = zeros(rows*N,1);
cacheDataBlock = zeros(rows*N,blockSizeWords);
cachedRow = zeros(N*rows,1);
cacheHit = 0;
cacheMiss = 0;
needLRU = zeros(N,1);
loop = 4;

% Accessing cache
for i=1:loop
    cacheHit = 0;
    cacheMiss = 0;
    for i=1:sequenceLength
        isHit = false;
        currentAddress = sequence(i);
        currentSet = mod(floor(currentAddress/(2^offset)),rows);
        currentSet = currentSet+1;
        currentTag = floor(sequence(i)/(blockSizeBytes*rows));
        for k=1:N
           if(cacheRowValidBit(currentSet+k,1)==1 && currentTag==cacheTag(currentSet+k,1))
               for a=1:blockSizeWords
                    if(currentAddress==cacheDataBlock(currentSet+k,a))
                      	isHit=true;
                        cacheHit = cacheHit+1;
                        fprintf('Accessing %d (set %d) (tag %d): hit from row %d\n',...
                   currentAddress,currentSet-1,currentTag,k) 
                    end
               end
           end
        end
        if(isHit==false)
            cacheMiss = cacheMiss+1;
            for a=1:N
                if(cachedRow(currentSet+a,1)==0)
                    if(a == rows)
                        needLRU(currentSet) = true; 
                    end
                cacheRowValidBit(currentSet+a,1)=1;
                cacheTag(currentSet+a,1)=currentTag;
                cachedRow(currentSet+a,1)=1;
                index = currentAddress;
                for b=1:blockSizeWords
                    data(b)= index;
                    index = index+4;
                end
               cacheDataBlock(currentSet+a,:)=data;
               fprintf('Accessing %d (set %d)(tag %d): miss - cached to row %d\n',...
                   currentAddress,currentSet-1,currentTag,a)
               break
           end
            end
            if(needLRU(currentSet) == 1)
                for b=1:N
               cachedRow(currentSet+b) = 0;
                end
                needLRU(currentSet) = 0;
            end
        end      
    end
    cost = cacheHit*hitTime+cacheMiss*missTime;
fprintf('Cost in cycles for this repetition: %d\n',cost);
fprintf('Average CPI: %f\n',cost/sequenceLength);
end

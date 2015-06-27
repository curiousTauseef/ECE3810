% Fully Associative Cache
clc        % clear command window
clear all  % clear all variables

% Initialize cache setup
sequence = [16 20 24 28 32 36 60 64 72 76 92 96 100 104 108 112 ...
            120 124 128 144 148];
wordBits = 32;                
valid = 1;                 
rows = 8;                  
blockSizeWords = 2;              
blockSizeBytes = (blockSizeWords*wordBits)/8;
blockSizeBits = blockSizeWords*wordBits;
offset = log2(blockSizeBytes);
LRU = ceil(log2(rows));
tag = 16-offset;
usedBits = rows*(valid+tag+blockSizeBits+LRU);
totalStorage = 900;
unusedBits = totalStorage-usedBits;
hitTime = 1;
missTime = 20+blockSizeBytes;

% Print out cache setup
fprintf('Fully associative cache with %d rows and %d bytes per row:\n',...
        rows, blockSizeBytes);
fprintf('Offset address bits: %d\n', offset);
fprintf('Bits in the valid bit: %d\n', valid);
fprintf('Bits in the data block: %d\n', blockSizeBits);
fprintf('Bits in the tag: %d\n', tag);
fprintf('Bits in the LRU: %d\n', LRU);
fprintf('Total bits used: %d, bits remaining: %d\n', usedBits,unusedBits);
fprintf('Hit time: %d\n', hitTime);
fprintf('Miss time: %d\n\n', missTime);

% Initialize cache
sequenceLength = length(sequence);
cacheValidBit = zeros(rows,1);
cacheTag = zeros(rows,1);
cacheDataBlock = zeros(rows,blockSizeWords);
cachedRow = zeros(rows,1);
cacheHit = 0;
cacheMiss = 0;
needLRU = 0;
loop = 2;

% Accessing cache
for i=1:loop
    cacheHit = 0;
    cacheMiss = 0;
    for i=1:sequenceLength
        isHit = false;
        currentAddress = sequence(i);
        currentTag = floor(sequence(i)/blockSizeBytes);
        for j=1:rows
            if(cacheValidBit(j,1)==1 && currentTag==cacheTag(j,1))
                for k=1:blockSizeWords
                    if(currentAddress==cacheDataBlock(j,k))
                        isHit = true;
                        cacheHit = cacheHit+1;
                    fprintf('Accessing %d (tag %d): hit from row %d\n',...
                       currentAddress,currentTag,j-1);
                    end
                end
            end
        end
        if(isHit==0)
            cacheMiss = cacheMiss+1;
            for a=1:rows
                if(cachedRow(a,1)==0)
                    if(a == rows)
                        needLRU = 1; 
                    end
                cacheValidBit(a,1)=1;
                cacheTag(a,1)=currentTag;
                cachedRow(a,1)=1;
                index = currentAddress;
                for b=1:blockSizeWords
                    data(b)= index;
                    index = index+4;
                end
               cacheDataBlock(a,:)=data;
               fprintf('Accessing %d (tag %d): miss - cached to row %d\n',...
                   currentAddress,currentTag,a-1)
               break
           end
        end
        if(needLRU == 1)
            cachedRow = zeros(rows,1);
            needLRU =0;
        end      
    end
end
cost = cacheHit*hitTime+cacheMiss*missTime;
fprintf('Cost in cycles for this repetition: %d\n',cost);
fprintf('Average CPI: %f\n',cost/sequenceLength);
end
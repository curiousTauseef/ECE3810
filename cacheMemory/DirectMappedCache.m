% Direct Mapped Cache
clc        % clear command window
clear all  % clear all variables

% Initialize cache setup
sequence = [16 20 24 28 32 36 60 64 72 76 92 96 100 104 108 112 ...
            120 124 128 144 148];
wordBits = 32;                
valid = 1; 
rows = 4; 
index = log2(rows);
blockSizeWords = 4;              
blockSizeBytes = (blockSizeWords*wordBits)/8;
blockSizeBits = blockSizeWords*wordBits;
offset = log2(blockSizeBytes);
tag = 16-offset-index;
usedBits = rows*(valid+tag+blockSizeBits);
totalStorage = 900;
unusedBits = totalStorage-usedBits;
hitTime = 1;
missTime = 20+blockSizeBytes;

% Print out cache setup
fprintf('Direct mapped cache with %d rows and %d bytes per row:\n',...
        rows, blockSizeBytes);
fprintf('Offset address bits: %d\n', offset);
fprintf('Bits in the index bit: %d\n', index);
fprintf('Bits in the valid bit: %d\n', valid);
fprintf('Bits in the data block: %d\n', blockSizeBits);
fprintf('Bits in the tag: %d\n', tag);
fprintf('Total bits used: %d, bits remaining: %d\n', usedBits,unusedBits);
fprintf('Hit time: %d\n', hitTime);
fprintf('Miss time: %d\n\n', missTime);

% Initialize cache
sequenceLength = length(sequence);
cacheValidBit = zeros(rows,1);
cacheTag = zeros(rows,1);
cacheDataBlock = zeros(rows,blockSizeWords);
cacheHit = 0;
cacheMiss = 0;
loop = 2;

% Accessing cache
for i=1:loop
    cacheHit = 0;
    cacheMiss = 0;
    for i=1:sequenceLength
        isHit = false;
        currentAddress = sequence(i);
        currentRow = mod(floor(currentAddress/(2^offset)),rows);
        currentTag = floor(sequence(i)/(blockSizeBytes*rows));
        if(cacheValidBit(currentRow+1,1)==1 && currentTag==cacheTag(currentRow+1,1))
            for j=1:blockSizeWords
               if(currentAddress==cacheDataBlock(currentRow+1,j))
                   isHit=true;
                   cacheHit = cacheHit+1;
                   fprintf('Accessing %d (index %d) (tag %d): hit from row %d\n',...
                   currentAddress,currentRow,currentTag,currentRow);
               end
            end
        end
        if(isHit==false)
            cacheMiss = cacheMiss+1;
            cacheValidBit(currentRow+1,1)=1;
            cacheTag(currentRow+1,1)=currentTag;
            count = currentAddress;
                for b=1:blockSizeWords
                    data(b)= count;
                    count = count+4;
                end
             cacheDataBlock(currentRow+1,:)=data;
             fprintf('Accessing %d (index %d) (tag %d): miss - cached to row %d\n',...
                   currentAddress,currentRow,currentTag,currentRow)
        end
        
    end
cost = cacheHit*hitTime+cacheMiss*missTime;
fprintf('Cost in cycles for this repetition: %d\n',cost);
fprintf('Average CPI: %f\n',cost/sequenceLength);
end
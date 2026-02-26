function [ber, numBits] = simula_qam3(EbNo, maxNumErrs, maxNumBits)
%BERTOOLTEMPLATE Template for a BERTool simulation function.
%   This file is a template for a BERTool-compatible simulation function.
%   To use the template, insert your own code in the places marked "INSERT
%   YOUR CODE HERE" and save the result as a file on your MATLAB path. Then
%   use the Monte Carlo panel of BERTool to execute the script.
%
%   [BER, NUMBITS] = YOURFUNCTION(EBNO, MAXNUMERRS, MAXNUMBITS) simulates a
%   communication system's error rate performance. EBNO is a vector of
%   Eb/No values, MAXNUMERRS is the maximum number of errors to collect
%   before stopping, and MAXNUMBITS is the maximum number of bits to run
%   before stopping.  BER is the computed bit error rate, and NUMBITS is
%   the actual number of bits run. 
%
%   For more information about this template and an example that uses it,
%   see the Communications Toolbox documentation.
%
%   See also BERTOOL, VITERBISIM.

% Copyright 2020-2021 The MathWorks, Inc.

narginchk(3,3)

% ==== DO NOT MODIFY if you intend to generate MEX file with MATLAB Coder. ====
% ==== Otherwise, you can remove the following two lines. ====
%#codegen
coder.extrinsic('isBERToolSimulationStopped')
% ==== END of DO NOT MODIFY ====

% Initialize variables related to exit criteria.
totErr  = 0; % Number of errors observed
numBits = 0; % Number of bits processed

% --- Set up parameters. ---
% --- INSERT YOUR CODE HERE.

constel_symb = [1+1i; 1-1i; -1-1i; -1+1i];  % 4-QAM - se escoge esta forma ya que es la mas simple y geometrica 

M = length(constel_symb); % numero de simbolos que hay 
k = log2(M); % numero de bits por cada simbolo

constel_bits = ['00'; '01'; '11'; '10']; % tabla de bits por simbolo (Gray code)

nBitsBloc = 10000; % bloque de bits por iteracion (ni muy pequeño ni muy grande) 
nSymbolsBloc = nBitsBloc/k;


EbNo_lin = 10^(EbNo/10);  %de dB a lineal

Ps = mean(abs(constel_symb).^2); %la potencia media

Eb = Ps/k; %energia por bit

Pn = Eb/EbNo_lin; %potencia del ruido 

% Simulate until number of errors exceeds maxNumErrs
% or number of bits processed exceeds maxNumBits.
while((totErr < maxNumErrs) && (numBits < maxNumBits))

    % Check if the user clicked the Stop button of BERTool.
    % ==== DO NOT MODIFY ====
    if isBERToolSimulationStopped()
        break
    end
    % ==== END of DO NOT MODIFY ====
  
    % --- Proceed with simulation.
    % --- Be sure to update totErr and numBits.
    % --- INSERT YOUR CODE HERE.

    RandSymb = randi([1 M], 1, nSymbolsBloc); % generamos los simbolos aleatorios ENTEROS
    
    mod = constel_symb(RandSymb); % modulamos -- mapeo vectorial 

    % ruido = nI + nQ 
    ruido = randn(1,nSymbolsBloc)+1i*randn(1,nSymbolsBloc); 

    ruidoFinal = sqrt(Pn/2)*ruido; % si no lo hacemos estariamos duplicando potencia 

    simRecivido = mod + ruidoFinal; 

    [detSym_idx, nerrors] = demodqam(simRecivido, constel_symb, constel_bits, RandSymb);

    totErr = totErr + nerrors;
    numBits = numBits + nBitsBloc;

end % End of loop

% Compute the BER.
ber = totErr/numBits;

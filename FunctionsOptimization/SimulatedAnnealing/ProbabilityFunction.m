function Probability = ProbabilityFunction(EnergyVariation, Temperature)

Probability = exp(-abs(EnergyVariation)./Temperature);

end

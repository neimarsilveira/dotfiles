set env(DO_QA) ON
# turn on creation of extract file
set num_threads 6
# set number of threads for Pardiso Solver

set env(VECLIB_MAXIMUM_THREADS) $num_threads
# set number of threads for Apple Accelerate Framework BLAS and LAPACK
# set number of threads for assemble
set env(MKL_NUM_THREADS) $num_threads
set env(OMP_NUM_THREADS) $num_threads

# Steps
set initial_step 1
set max_steps 200

# create a linear analysis object
analysis create nonlinearCohesive
analysis setParallelAssemble
analysis nonSolOption numTimeSteps $max_steps
analysis nonSolOption solAlgorithm newton
analysis nonSolOption convTolerance 5.0e-6
analysis nonSolOption convCriterion residual
analysis nonSolOption maxNumNonlinIters 20
analysis nonSolOption isLineSearch false
analysis nonSolOption loadIncrType uniform
analysis nonSolOption isShapeFnTimeDepen false

# ------------ Use pFEM-GFEM approximation space ----------
# It gives better SIFs as GFEM but implementation is
# not as robust as GFEM for crack propagation at this time.
parSet useCompElPfemGfem true

# shifting non polynomial enrichments
parSet ShiftedSpBasisEnrichments true

# ------------ Direct Method for BCs due to Classic FEM elements ------------
parSet directMethodForPtDirichletBC  true

# ------------ Read the model ----------
readFile "cohesive_model_coarse.grf" phfile

# ------------ CRACK MANAGER ----------
# create crack manager
crackMgr crackMgrID 2 create crackFile "crack_85.crf"

# refine initial crack
# crackMgr crackMgrID 2 postSurface "crack_surf_initial.vtk"
# crackMgr crackMgrID 2 setOptions frontEdgeLengthLimit 1.0
# crackMgr crackMgrID 2 setOptions crackSurfEdgeLength 1.0
# crackMgr crackMgrID 2 remeshCrackSurface
# crackMgr crackMgrID 2 postSurface "crack_surf_after_remeshing.vtk"

# crack manager options
crackMgr crackMgrID 2 setOptions useBranchFn false
crackMgr crackMgrID 2 setOptions useCohesive CohesiveCrackBilinear

# pGFEM requires usePlanarcutssignedDist
crackMgr crackMgrID 2 setOptions usePlanarCutsSignedDist true


# ------------ REFINE 3D ELEMENTS CUT BY CRACK SURFACE  ---------
set size_around_crack_surf 5.0
crackMgr crackMgrID 2 refineMesh crackSurface maxEdgeLen $size_around_crack_surf

# Snap to the crack surface nodes that are close to it
# This improves conditioning of global matrix
crackMgr crackMgrID 2 setOptions snapNodesToSurfAndFront snappingTolSurf 0.05 snappingTolFront 0.05

# ------------ PROCESS CRACK SURFACE ------------ 
# cut elements, select enrichments, etc
crackMgr crackMgrID 2 process

# ------------ APPROXIMATION ORDER ----------
# apply uniform polynomial enrichment of order p to the approximation
set p_global 1
enrichApprox iso approxOrder $p_global

# apply polynomial enrichment of order p around the crack surface 
set p_crack_surf 2
set n_layers_enrich 1
crackMgr crackMgrID 2 enrichApprox crackSurface numElemLayers $n_layers_enrich iso approxOrder $p_crack_surf

# NOTE: BCs are applied to beam nodes only, so no need to 
# deal with approx order of BC regions.

# ------------ POST PROCESSING QUANTITIES ------------ 
graphMesh appendName  Solution
graphMesh appendName  SolU
graphMesh appendName  SolV
graphMesh appendName  SolW
graphMesh appendName  Sxx
graphMesh appendName  Syy
graphMesh appendName  Szz
graphMesh appendName  Sxy
graphMesh appendName  Syz
graphMesh appendName  Sxz

# ------------ CHECK INPUT MESH ----------
graphMesh create "sena_input.vtu"  VTKStyle
graphMesh postProcess resolution 0 sampleInside
# exit

# ------------ STEPS ----------
set initial_total_time [ clock clicks -milliseconds ]
for {set kstep $initial_step} {$kstep <= $max_steps} {incr kstep} {

    set initTime [ clock clicks -milliseconds ]

    # graphMesh create "sena_$kstep.vtu"  VTKStyle
    analysis nonlinearSolve timeStep $kstep
    # graphMesh postProcess resolution 0 sampleInside

        
    # compute nodal reactions at loading points
    extractFile create
    computeNodReaction cnode 1
    # computeNodReaction cnode 2

    extractQuantity Solution point -2.5 100 100
    extractQuantity Solution point 2.5 100 100

    set finalTime [ clock clicks -milliseconds ]
    set totalTime_afp [expr ( $finalTime - $initTime ) / 1.0e3 ]
    puts stdout "\nTime spent for step $kstep: $totalTime_afp s \n"

}

set final_total_time [ clock clicks -milliseconds ]
set final_total_time [expr ($final_total_time - $initial_total_time ) / 1.0e3 ]
puts stdout "\nTotal time spent in simulation: $final_total_time s \n"


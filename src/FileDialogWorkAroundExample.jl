module FileDialogWorkAroundExample
# instead of
# using NativeFileDialog
# add following lines
include("FileDialogWorkAround.jl")
using .FileDialogWorkAround

# if you need file dialog functions outside of your package, you can re-export them:
export pick_file, pick_folder, pick_multi_file, save_file
# otherwise use them in exactly the way you used them from 
# NativeFileDialog package

end # module FileDialogWorkAroundExample

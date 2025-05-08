"use client";

import * as React from "react";
import { Check } from "lucide-react";

import { cn } from "@/lib/cn";

interface CheckboxProps extends React.InputHTMLAttributes<HTMLInputElement> {
  checked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  label?: string;
}

const Checkbox = React.forwardRef<HTMLInputElement, CheckboxProps>(
  ({ className, checked, onCheckedChange, ...props }, ref) => {
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      if (onCheckedChange) {
        onCheckedChange(e.target.checked);
      }
    };

    return (
      <div className="relative flex items-center">
        <input
          type="checkbox"
          ref={ref}
          checked={checked}
          onChange={handleChange}
          className="sr-only"
          {...props}
        />
        <div
          className={cn(
            "flex h-4 w-4 items-center justify-center rounded-sm border",
            checked
              ? "border-primary bg-primary text-primary-foreground"
              : "border-input",
            props.disabled && "opacity-50 cursor-not-allowed",
            className
          )}
        >
          {checked && <Check className="h-3 w-3 text-white" />}
        </div>
      </div>
    );
  }
);

Checkbox.displayName = "Checkbox";

export { Checkbox };

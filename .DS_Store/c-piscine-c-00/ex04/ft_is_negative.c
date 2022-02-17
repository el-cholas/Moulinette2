/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_is_negative.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/15 15:58:38 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/15 19:55:58 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>

/*
Fucking norminette doesn't let me comment where I want to
*/

void	print(char string[])
{
	int	i;

	i = 0;
	while (string[i] != '\0' && i < 2147483647)
	{
		write(1, &string[i], 1);
		i++;
	}
}

void	ft_is_negative(int i)
{
	if (i < 0)
		print("N");
	else
		print("P");
}
